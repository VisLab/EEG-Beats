function [peaksFinalIdx, peaksFinalTm] = getBeatRefinement(ekg, t, srate, below, above, qrsDuration)
%% Find R peaks within an electrocardiogram signal. 
% [peaksFinal] = getHeartBeats(ekg, t, srate, below, above, eps)
% 
% getHeartBeats is used to detect R peaks of an electriocardiogram. 
% peaksFinal is an array of sample numbers that contain R peaks. 
% 
%   Parameters:
%      ekg      The EKG signal after filtering. 
%      t        A array of samples.  
%      srate    The sampling rate of the EKG signal. Should be 200, if not then
%               the signal is resampled to 200.
%      below    The minimum time in seconds allowed between consecutive R peaks. 
%               Recommended time is .6.
%      above    The maximum time in seconds allowed between consecutive R peaks. 
%               Recommended time is 1.5.
%      peaksFinalIdx
%               (output) An array of indices of suspected R peaks within the EKG
%               signal.
%      peaksFinalTm
%               (output) An array of times of suspected R peaks within the EKG
%               signal.
%      qrsDuration
%               The width of a peak in seconds
%
%   Global Variables:
%      maxDist  The maximum amount of time allowed between R peaks in terms
%               of sample numbers. 
%      minDist  The minimum amount of time allowed between R peaks in terms
%               of sample numbers.
%      lowerThreshold  
%               The maximum value a peak can have to be considered an
%               S peak.
%      upperThreshold  
%               The minimum value a peak can have to be considered an
%               R peak. 
%
%   Example:
%       [peaksFinalIdx] = getBeatRefinement(EEG, t, below, above, eps)
%%
 
%% Set up variables
% Use initialParseIBI to find a preliminary estimate of the peaks.
% Epsilon is the number of samples in the peak width
% minimum qrs duration is how wide the peak should be
epsIdx = round(qrsDuration*srate); %(.10 * 200), QRS duration * sample rate
if epsIdx == 0
    error('Invalid qrsDuration or srate: qrsDuration*srate must be > 0. Given: %d * %d = %d', qrsDuration, srate, epsIdx);
end

ekgOriginal = ekg;

% convert the rate and the time to index sizes in an array
minDistIdx = max(round(below*srate), 1);
lowerThreshold = median(ekg)-(2*1.4826*mad(ekg,1));
upperThreshold = median(ekg)+(2*1.4826*mad(ekg,1));

%% Determine whether or not to flip the ekg signal
flip = determineIfFlip(ekg, median(ekg)+(15*1.4826*mad(ekg,1)));
if flip
    ekg = -ekg;
    lowerThreshold = median(ekg)-(2*1.4826*mad(ekg,1));
    upperThreshold = median(ekg)+(2*1.4826*mad(ekg,1));
end

%% Get the original peaks
mask = initialParseIBI(ekg);

indices = 1:1:length(ekg);
peaksIdx = [1, indices(mask), length(t)];  %Array of suspected peaks given in sample numbers. Treated as a queue
peaksFinalIdx = [];
figure;
plot(ekg);
ekg = zeroOut(ekg, peaksIdx); %Zero out the signal around suspected peaks

%% Get the other peaks
while (length(peaksIdx) > 1) %Loop while suspeced peaks exist
    %if peaksIdx(1) >= 415*srate
        %figure;
        %x = peaksIdx(1) / srate;
        %plot(ekg(peaksIdx(1):peaksIdx(2)));%peaksIdx(1):peaksIdx(2), ekg(peaksIdx(1):peaksIdx(2)));
    %end
    innerBeat = getRefinement(peaksIdx(1), peaksIdx(2));
    %See if there are more peaks between suspected peaks
    if isempty(innerBeat) %No new peaks exists between the first and last beat
        if peaksIdx(1) ~= 1
            peaksFinalIdx = [peaksFinalIdx, peaksIdx(1)]; %Add firstBeat to the final list
        end
        peaksIdx = peaksIdx(2:end); %Make t2 the new start of the suspected peaks list
    else
        if innerBeat ~= -1
            peaksIdx = [peaksIdx(1) innerBeat peaksIdx(2:end)]; %tb is a suspected peak. Add it to the list
        end
    end
end


if flip
    peaksFinalIdx = getPeaksFromTroughs(ekgOriginal, peaksFinalIdx);
end
peaksFinalTm = peaksFinalIdx * srate + 1;

    function flip = determineIfFlip(ekg, invalidMax)
    %%
    % Parameters: 
    %   ekg the data to base off ofccc
    % Purpose:
    %   Determine if the ekg data needs to be converted to the negative.
    %%
        flip = false;
        % Get the maximum value
        [~, maxIdx] = max(ekg);
        if ekg(maxIdx) < upperThreshold
            return
        end
        % Get the miniumum value around that peak
        [interval1Idx, ~] = max([maxIdx-2*epsIdx, 1]);
        [interval2Idx, ~] = min([maxIdx+2*epsIdx, length(ekg)]);
        [~, minIdx] = min(ekg(interval1Idx:interval2Idx));
        minIdx = minIdx + interval1Idx-1;
        if ekg(minIdx) > lowerThreshold || ekg(maxIdx) > invalidMax
            ekg = zeroOut(ekg, maxIdx);
            flip = determineIfFlip(ekg, invalidMax);
        end
        
        % You need to flip the ekg
        if maxIdx > minIdx
            flip = true;
        end
        return        
    end
    function innerBeatIdx = getRefinement(firstBeatIdx, lastBeatIdx)
    %% Find a beat peak between two existing beats if it exists
    %
    % Parameters:
    %   firstBeatIdx The index of the beat farthest to the left. 
    %   lastBeatIdx  The index of the beat farthest to the right.
    %   innerBeatIdx (output) is the index of the inner beat...empty
    %   
    %   Example:
    %       innerBeatIdx = getRefinement(firstBeatIdx, lastBeatIdx)
    %%
        innerBeatIdx = [];
        
        % very unlikely to find a heartbeat in this range
        if lastBeatIdx - firstBeatIdx < minDistIdx %IBI < maxDist (1.5 s)
            return;
        end 

        thisSignal = ekg(firstBeatIdx:lastBeatIdx);
        
        %Find the maximum between two known peaks
        [~,innerBeatBaseIdx] = max(thisSignal); %index of the max from first beat
        
        % For the case that everything in that interval is <= 0
        if notFeasible(firstBeatIdx, innerBeatBaseIdx, lastBeatIdx) %Not a valid peak
           innerBeatIdx = innerBeatBaseIdx + firstBeatIdx - 1; 
           if (ekg(innerBeatIdx)) < upperThreshold
               innerBeatIdx = [];
               return;
           end
           ekg = zeroOut(ekg, innerBeatIdx);
           innerBeatIdx = -1;
        else
           innerBeatIdx = innerBeatBaseIdx + firstBeatIdx - 1; 
           ekg = zeroOut(ekg, innerBeatIdx);
        end
    end	

    function ekg = zeroOut(ekg, peaksIdx)
     %% Zero out the surrounding signal around suspected R peaks.
     %
     %  Parameters:
     %      ekg         The EKG signal prior to zeroing out.
     %      peaksIdx    An array of suspected R peaks in samples.
     %      ekg         (output) The EKG signal that has been zeroed out around
     %                  the R peaks.
     %
     %  Example:
     %      ekg = zeroOut(ekg, peaksidx, below, above, srate)
     %%
        for k = 1:length(peaksIdx) %Zero out area around peaks
           firstSampleIdx = round(max(1, peaksIdx(k) - epsIdx)); %Max between 1 and tb-below
           lastSampleIdx = round(min(peaksIdx(k) + epsIdx, length(ekg))); %Min between tb+above and length of ekg
           ekg(firstSampleIdx: lastSampleIdx) = 0;
        end
        
        
    end

    function result = determineIfPeak(beatIdx, endValue)
        %%
        % Determine if the value at the peak is actually a peak.
        % Parameters:
        %    beatIdx   the index of the peak
        %%
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        negSignal = -ekg(beatIdx:endValue);%firstBeatIdx:lastBeatIdx);
        if isempty(negSignal)
            result =1;
            return;
        end
        
        % find the locations of the troughs
        negTime = 1:length(negSignal);
        [sVal,sLocs,~,~] = findpeaks(double(negSignal), negTime,...
                        'MinPeakHeight', -lowerThreshold);
        
        %[~,index] = min(abs(sLocs-innerBeatBaseIdx));
        %index = sLocs(1);
        
        if isempty(sLocs) || sLocs(1) >= epsIdx || ...
                ~(-sVal(1)  < lowerThreshold)
            result = 1;
        else
            result = 0; 
        end      
    end
    function result = notFeasible(firstBeatIdx, innerBeatBaseIdx, lastBeatIdx)
    %% Determine if the innerBeatBaseIdx meets the criteria for an R peak.
    % 
    % notFeasible determines if innerBeatBaseIdx meets the criteria for being an R
    %   peak. Inner beat's R and S peaks must above the upper threshold and 
    %   below the lower threshold respectively and has to be a minimum of minDist
    %   away from the firstBeatIdx and lastBeatIdx and a maximum of maxDist away from 
    %   firstBeatIdx and lastBeatIdx.
    %
    % Parameters:
    %   firstBeatIdx        The beat farthest to the left.
    %   innerBeatBaseIdx   The suspected beat between firstBeatIdx and lastBeatIdx.
    %   lastBeatIdx         The beat farthest to the right. 
    %   result              (output) Logical 1 or 0 depending if the innerBeatBaseIdx
    %                       meets the criteria to be an R peak. 
    %
    %   Example:
    %       result = notFeasible(firstBeatIdx, innerBeatBaseIdx, lastBeatIdx)
    %%
        % Get the upper peak value
        if (innerBeatBaseIdx == 1) || ...
            (innerBeatBaseIdx + firstBeatIdx - 1 == lastBeatIdx)
            result = 1;
            return
        end
        
        % innerBeatBaseIdx is two close to firstBeatIdx or lastBeatIdx
        if ~(minDistIdx < innerBeatBaseIdx-1) || ...
            ~(lastBeatIdx - minDistIdx > innerBeatBaseIdx+firstBeatIdx-1)
            result = 1;
            return;
        end
    
        result = determineIfPeak(innerBeatBaseIdx+firstBeatIdx-1,lastBeatIdx);
        return; 
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        negSignal = -ekg(innerBeatBaseIdx+firstBeatIdx-1:lastBeatIdx);%firstBeatIdx:lastBeatIdx);
        if isempty(negSignal)
            result =1;
            return;
        end
        
        % find the locations of the troughs
        negTime = 1:length(negSignal);
        [sVal,sLocs,~,~] = findpeaks(double(negSignal), negTime,...
                        'MinPeakHeight', -lowerThreshold);
        
        %[~,index] = min(abs(sLocs-innerBeatBaseIdx));
        %index = sLocs(1);
        
        if isempty(sLocs) || sLocs(1) >= epsIdx || ...
                ~(-sVal(1)  < lowerThreshold)
            result = 1;
        else
            result = 0; 
        end        
        
        % Error detecting peak
        %if isempty(index) || length(index) ~= 1 || ...
         %       sLocs(index) >= epsIdx
          %  result = 1;
           % return;
        %end
        
        % get a lower peak value.
        %lowerPeak = sVal(index);
        
        % Determine if it is valid
        % should be below the lowerThreshold
        %if ~(-lowerPeak < lowerThreshold)
         %   result = 1;
        %else
        %    result = 0; 
        %end
        return;
    end

    function [idx] = initialParseIBI(signal)
    %% Find a small number of suspected R peaks throughout the signal.
    %
    %   Parameters: 
    %       signal  The EKG signal
    %       idx     (output) An array of indices containing suspected R
    %               peaks in samples. 
    %   Example:
    %       idx = initialParseIBI(signal)
    %%
        a = min(signal)*.15; 
        index = find((signal - a) < 20 & signal > (a-1)); %handful of R peaks 
        b = 1;
        for i = 1:(length(index)+1)
            if i < (length(index) +1)
                thisIdx = index(i);
            end
            % Get a range of values before the first found peak.
            if i == 1
                thisSignal = signal(1:thisIdx);
            end
            % Get a range of values after the first found peaks
            if i == (length(index)+1)
                thisIdx = index(end);
                thisSignal = signal(thisIdx:end);
            end
            % Get a range of values between two peaks.
            if ~(i==1) && ~(i==(length(index)+1))
                % redundant: thisIdx = index(i);
                thisSignal = signal(index(i-1):thisIdx);
                thisIdx = index(i-1);
            end
            [yValue, yValueIdx] = max(thisSignal);
            
            % if it is actually a peak, add it to the list
            if yValue > upperThreshold && ...
                    determineIfPeak(yValueIdx+thisIdx-1, ...
                    min(yValue+thisIdx+epsIdx*2, length(thisSignal)))
                maxValues(b) = yValue;
                b = b + 1;
            end
        end
        
        % Note that the ' operator is for transpose.
        % M' = transpose(M) for the matrix M
        if ~isrow(maxValues)
            maxValues = maxValues';
        end
        % just set the matching indices to true
        maxValuesFew = maxk(maxValues, max(floor(length(maxValues)/5), 2));
        idx = ismember(signal', maxValuesFew);
    end

    function realPeaksIdx = getPeaksFromTroughs(ekg, troughsIdx)
    %%
    % If we just have the troughs of the ekg data, get the peaks of the
    % data.
    % Parameters
    %    ekg            the data to get the peaks from
    %    troughsIdx     the indices of the troughs
    % Returns
    %    realPeaksIdx   the indices of the actual peaks
    %%
        realPeaksIdx = [];
        for i = 1:length(troughsIdx)
            [interval1Idx, ~] = max([troughsIdx(i), 1]);
            [interval2Idx, ~] = min([troughsIdx(i)+epsIdx, length(ekg)]);
            [~, maxIdx] = max(ekg(interval1Idx:interval2Idx));
            maxIdx = maxIdx + interval1Idx-1;
            if maxIdx == 1 || maxIdx == length(ekg) ...
                    || ekg(maxIdx) < upperThreshold
                continue;
            end
            realPeaksIdx = [realPeaksIdx maxIdx];
        end
    end
end 