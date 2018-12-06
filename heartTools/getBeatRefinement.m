function [peaksFinalIdx, peaksFinalTm] = getBeatRefinement(ekg, t, srate, below, above, qrsDuration, consensusIntervalLen)
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
%      qrsDuration
%               The width of a peak in seconds
%      peaksFinalIdx
%               (output) An array of indices of suspected R peaks within the EKG
%               signal.
%      peaksFinalTm
%               (output) An array of times of suspected R peaks within the EKG
%               signal.
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

% 
lowerMax = getAvgMin(ekg)-(10*1.4826*mad(ekg,1));
upperMax = getAvgMax(ekg)+(10*1.4826*mad(ekg,1));
ekg(ekg < lowerMax) = lowerMax;
ekg(ekg > upperMax) = upperMax;
ekgOriginal = ekg;

% convert the rate and the time to index sizes in an array
minDistIdx = max(round(below*srate), 1);
lowerThreshold = median(ekg)-(1.5*1.4826*mad(ekg,1));
upperThreshold = median(ekg)+(1.5*1.4826*mad(ekg,1));

%% Determine whether or not to flip the ekg signal
flip = getConsensus(ekg, 1);
if flip
    ekg = -ekg;
    lowerThreshold = median(ekg)-(1.5*1.4826*mad(ekg,1));
    upperThreshold = median(ekg)+(1.5*1.4826*mad(ekg,1));
    ekgOriginal = -ekgOriginal;
end
lowerThresholdLarge = median(ekg)-(3.5*1.4826*mad(ekg,1));
upperThresholdLarge = median(ekg)+(3.5*1.4826*mad(ekg,1));
sigRight = getConsensus(ekg, 2);


%% Get the original peaks
mask = initialParseIBI(ekg);
maskTroughs = zeros(length(mask),1);

% Make sure the peaks are valid
for iter = 1:length(mask)
    if mask(iter) == 1
        % Zero out the peaks or mark them as invalid
        if sigRight
            [result, beatIdx] = ...
                determineIfPeak(iter, min(length(ekg), iter+epsIdx*2));
        else
            [result, beatIdx] = ...
                determineIfPeak(iter, max(iter-epsIdx*2, 1));
        end
        % set up the peak stuff
        if result
            ekg = zeroOut(ekg, iter);
            maskTroughs(beatIdx(2)) = 1;
        else
            mask(iter) = 0;
        end
    end
end

maskTroughs = logical(maskTroughs);
initIndices = 1:length(ekg);
% Array of suspected peaks given in sample numbers. Treated as a queue
peaksIdx = [1, initIndices(mask), length(t);...
    1, initIndices(maskTroughs), length(t)];  

peaksFinalIdx = [];
%% Get the other peaks
sizeOfPeaks = size(peaksIdx);
while (sizeOfPeaks(2) > 1) %Loop while suspected peaks exist
    innerBeat = getRefinement(peaksIdx(1,1), peaksIdx(1,2));
    %See if there are more peaks between suspected peaks
    if isempty(innerBeat) %No new peaks exists between the first and last beat
        if peaksIdx(1) ~= 1
            peaksFinalIdx = [peaksFinalIdx, peaksIdx(:,1)]; %Add firstBeat to the final list
        end
        peaksIdx = peaksIdx(:,2:end); %Make t2 the new start of the suspected peaks list
    else
        if innerBeat ~= -1
            peaksIdx = [peaksIdx(:,1) innerBeat peaksIdx(:,2:end)]; %tb is a suspected peak. Add it to the list
        end
    end
    sizeOfPeaks = size(peaksIdx);
end


peaksFinalIdx = cleanPeaks(peaksFinalIdx);
if flip
    peaksFinalIdx = flipPeaksAndTroughs(peaksFinalIdx);
end
peaksFinalTm = (peaksFinalIdx-1)/srate;

    function cons = getConsensus(ekg, consType)
        %% Compare multiple different intervals to determine if to flip
        % Parameters:
        %       ekg             the data to get the consensus
        %       consType        the type of consensus to get 
        %                       (1 = flip, 2 = peakDir)
        % Result:
        %       cons            if consType = 1;
        %                           true = flip, false = not flip
        %                       if consType = 2;
        %                           true = troughRight, false = troughLeft
        %% 
        % within that interval. Generate a consensus for that.
        consensusIntervalIdx = consensusIntervalLen * srate;
        numIntervals = min(length(ekg)/consensusIntervalIdx, 10);
        maxIntervalLenIdx = floor(length(ekg)/numIntervals);
        startIdx = zeros(1,numIntervals);
        
        % get the start indices for the intervals
        if maxIntervalLenIdx == consensusIntervalIdx 
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1;
            end
        else
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1 + ...
                    floor(rand() * (maxIntervalLenIdx - consensusIntervalIdx));
            end
        end
        
        % calculate if flip is true for each interval
        % for each interval do determine is flip. Then determine
        % consensus
        consCnt = 0;
        for i = 1:numIntervals
            if consType == 1
                consCnt = consCnt + ...
                    determineIfFlip( ...
                    ekg(startIdx(i):startIdx(i)+consensusIntervalIdx));
            elseif consType == 2
                consCnt = consCnt + ...
                    determineIfTroughRight( ...
                    ekg(startIdx(i):startIdx(i)+consensusIntervalIdx));
            end
            
        end
        if consCnt >= ceil(numIntervals/2)
            cons = true;
        else
            cons = false;
        end
    end

    function minVal = getAvgMin(ekg)
         %% Compare multiple different intervals to determine an average minimum
        % Parameters:
        %       ekg             the data to get the consensus
        %       consType        the type of consensus to get 
        %                       (1 = flip, 2 = peakDir)
        % Result:
        %       minVal          the average minimum
        %% 
        % Set up the intervals.
        consensusIntervalIdx = consensusIntervalLen * srate;
        numIntervals = min(length(ekg)/consensusIntervalIdx, 10);
        maxIntervalLenIdx = floor(length(ekg)/numIntervals);
        startIdx = zeros(1,numIntervals);
        
        % get the start indices for the intervals
        if maxIntervalLenIdx == consensusIntervalIdx 
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1;
            end
        else
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1 + ...
                    floor(rand() * (maxIntervalLenIdx - consensusIntervalIdx));
            end
        end
        
        % Get the minimum value for the interval
        total = 0;
        for i = 1:numIntervals
            total = total + min(ekg(startIdx(i):startIdx(i)+consensusIntervalIdx));
        end
        minVal = total / (numIntervals*1.0);
    end
    function maxVal = getAvgMax(ekg)
         %% Compare multiple different intervals to determine an average maximum
        % Parameters:
        %       ekg             the data to get the consensus
        %       consType        the type of consensus to get 
        %                       (1 = flip, 2 = peakDir)
        % Result:
        %       maxVal          the average maximum
        %% 
        % Set up the intervals
        consensusIntervalIdx = consensusIntervalLen * srate;
        numIntervals = min(length(ekg)/consensusIntervalIdx, 10);
        maxIntervalLenIdx = floor(length(ekg)/numIntervals);
        startIdx = zeros(1,numIntervals);
        
        % get the start indices for the intervals
        if maxIntervalLenIdx == consensusIntervalIdx 
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1;
            end
        else
            for i = 1:numIntervals
                startIdx(i) = (i-1)*maxIntervalLenIdx + 1 + ...
                    floor(rand() * (maxIntervalLenIdx - consensusIntervalIdx));
            end
        end
        
        % Sum um the maximum values per interval
        total = 0;
        for i = 1:numIntervals
            total = total + max(ekg(startIdx(i):startIdx(i)+consensusIntervalIdx));
        end
        maxVal = total / (numIntervals*1.0);
    end

    function flip = determineIfFlip(ekg)
    %%
    % Parameters: 
    %   ekg the data to base off of
    % Purpose:
    %   Determine if the ekg data needs to be flipped.
    %%
        flip = 0;
        
        % Get the maximum value
        [~, maxIdx] = max(ekg);
        [~, minIdx] = min(ekg);
        if ekg(maxIdx) < upperThreshold && ekg(minIdx) > lowerThreshold
            return
        end
        % You need to flip the ekg
        if abs(ekg(maxIdx)) < abs(ekg(minIdx))
            flip = 1;
        end
    end

    function troughRight = determineIfTroughRight(ekg)
    %%
    % Parameters: 
    %   ekg the data to base off of
    % Purpose:
    %   Determine if the trough of the peak is to the right
    %%
        troughRight = 0;
        
        % Get the maximum value
        [~, maxIdx] = max(ekg);
        
        % Get the miniumum value around that peak
        [interval1Idx, ~] = max([maxIdx-2*epsIdx, 1]);
        [interval2Idx, ~] = min([maxIdx+2*epsIdx, length(ekg)]);
        
        % Trough left
        negSigLeft = -ekg(interval1Idx:maxIdx);
        if isempty(negSigLeft) || length(negSigLeft) < 3 
            return;
        end
        negTimeLeft = 1:length(negSigLeft);
        [sValL,sLocsL,~,~] = findpeaks(double(negSigLeft), negTimeLeft, ...
            'MinPeakHeight', -lowerThreshold);
        if isempty(sLocsL) || sLocsL(1) >= epsIdx
            return;
        end
        
        % Trough right
        troughRight = 1;
        negSigRight = -ekg(interval2Idx:maxIdx);
        if isempty(negSigRight) || length(negSigRight) < 3 
            return;
        end
        negTimeRight = fliplr(1:length(negSigRight));
        [sValR,sLocsR,~,~] = findpeaks(double(negSigRight), negTimeRight, ...
            'MinPeakHeight', -lowerThreshold);
        if isempty(sLocsR) || sLocsR(1) >= epsIdx
            return;
        end
        
        % Go left
        if sValL(1) > sValR(1)
            return;
        end
        
        troughRight = 0;
        return;
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
        [notFeasibleVal, innerBeatIdx] = ...
            notFeasible(firstBeatIdx, innerBeatBaseIdx, lastBeatIdx);
        if notFeasibleVal %Not a valid peak
           if (ekg(innerBeatIdx)) < upperThreshold
               innerBeatIdx = [];
               return;
           end
           ekg = zeroOut(ekg, innerBeatIdx(1,1));
           innerBeatIdx = -1;
        else
           ekg = zeroOut(ekg, innerBeatIdx(1,1));
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

    function [result, innerBeatIdx] = determineIfPeak(beatIdx, endValue)
        %%
        % Determine if the value at the peak is actually a peak.
        % Parameters:
        %    beatIdx   the index of the peak
        %%
        innerBeatIdx = [beatIdx; beatIdx];
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        if sigRight
            negSignal = -ekg(beatIdx:endValue);%firstBeatIdx:lastBeatIdx);
        else
            negSignal = fliplr(-ekg(endValue:beatIdx));
        end
        if isempty(negSignal) || length(negSignal) < 3
            result = 0;
            return;
        end
        
        % find the locations of the troughs
        negTime = 1:length(negSignal);
        [sVal,sLocs,~,~] = findpeaks(double(negSignal), negTime,...
                        'MinPeakHeight', -lowerThreshold);

        %[~,index] = min(abs(sLocs-innerBeatBaseIdx));
        %index = sLocs(1);
        
        if isempty(sLocs) || sLocs(1) >= epsIdx || ...
                ~(-sVal(1)  < lowerThreshold && ...
                ekg(beatIdx) > upperThreshold)
            result = 0;
            return;
        end
        if sigRight
            innerBeatIdx = [beatIdx; sLocs(1) + beatIdx - 1];
        else
            innerBeatIdx = [beatIdx; beatIdx - sLocs(1) + 1];
        end
        result = 1;
    end
    function [result, innerBeatIdx] = notFeasible(firstBeatIdx, innerBeatBaseIdx, lastBeatIdx)
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
        innerBeatIdx = [innerBeatBaseIdx+firstBeatIdx-1, innerBeatBaseIdx+firstBeatIdx-1];
        
        % Ensure not an end point
        if (innerBeatBaseIdx == 1) || ...
            (innerBeatBaseIdx + firstBeatIdx - 1 == lastBeatIdx) || ...
            abs(lastBeatIdx-firstBeatIdx) < epsIdx
            result = 1;
            return
        end
        
        % innerBeatBaseIdx is two close to firstBeatIdx or lastBeatIdx
        if ~(minDistIdx < innerBeatBaseIdx-1) || ...
            ~(lastBeatIdx - minDistIdx > innerBeatBaseIdx+firstBeatIdx-1)
            result = 1;
            return;
        end
        
        if sigRight
            [result, innerBeatIdx] = ...
                determineIfPeak(innerBeatBaseIdx+firstBeatIdx-1,lastBeatIdx);
        else
            [result, innerBeatIdx] = ...
                determineIfPeak(innerBeatBaseIdx+firstBeatIdx-1,firstBeatIdx);
        end
            
        result = ~result;
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
    %
        a = min(signal)*.15; 
        maxValues = [];
        index = find((signal - a) < 20 & signal > (a-1)); %handful of R peaks 
        if length(index) == 0
            error('Invalid data: Unable to find any peaks');
        end
        
        b = 1;
        for i = 1:(length(index)+1)
            if i < (length(index) +1)
                thisIdx = index(i);
            end
            % Get a range of values after the first found peaks
            if i == (length(index)+1)
                thisIdx = index(end);
                thisSignal = signal(thisIdx:end);
            elseif i == 1
            % Get a range of values before the first found peak.
                thisSignal = signal(1:thisIdx);
            end
            % Get a range of values between two peaks.
            if ~(i==1) && ~(i==(length(index)+1))
                % redundant: thisIdx = index(i);
                thisSignal = signal(index(i-1):thisIdx);
                thisIdx = index(i-1);
            end
            [yValue, ~] = max(thisSignal);
            
            % if it is big enough, add it to the list
            if yValue > upperThreshold 
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

    function realPeaksIdx = flipPeaksAndTroughs(peaksIdx)
    %%
    % Flip the peaks and troughs
    % Parameters
    %    ekg            the data to get the peaks from
    %    peakssIdx      the original indices of the peaks
    % Returns
    %    realPeaksIdx   the indices of the actual peaks
    %%
        realPeaksIdx = [peaksIdx(2,:); peaksIdx(1,:)];
    end
    
    function cleanedPeaks = cleanPeaks(peaksIdx)
    %% 
    % Clean up the peaks to remove unused values
    % Parameters
    %   peaksIdx        index of the peaks
    % Returns
    %   cleanedPeaks    the cleaned result
    %%
        cleanedPeaks = [];
        for i = 1:length(peaksIdx)
            % exclude repeated peaks or non-peaks (i.e., peak = trough)
            if peaksIdx(1, i) == peaksIdx(2, i) || ...
                    (~isempty(cleanedPeaks) && ...
                    peaksIdx(1,i) == cleanedPeaks(1, end)) || ...
                    (ekgOriginal(peaksIdx(1,i)) < upperThresholdLarge && ...
                    ekgOriginal(peaksIdx(2,i)) > lowerThresholdLarge)
                continue;
            end
            cleanedPeaks = [cleanedPeaks peaksIdx(:,i)];
        end
    end
end 