function [peaksFinal] = getBeatRefinement(ekg, t, srate, below, above)
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
%               the signal is resample to 200.
%      below    The minimum time in seconeds allowed between consecutive R peaks. 
%               Recommended time is .6.
%      above    The maximum time in seconds allowed between consecutive R peaks. 
%               Recommended time is 1.5.
%      peaksFinal 
%               (output) An array of suspected R peaks within the EKG
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
%       [peaksFinal] = getBeatRefinement(EEG, t, below, above, eps)
%%
 

% Use initialParseIBI to find a preliminary estimate of the peaks. 
eps = 20; %(.10 * 200), QRS duration * sample rate
idx = initialParseIBI(ekg, eps);

maxDist = round(above*srate);
minDist = round(below*srate);
lowerThreshold = median(ekg)-(1.4826*mad(ekg,1));
upperThreshold = median(ekg)+(1.4826*mad(ekg,1));
eps = 20;
peaks = [1, t(idx), t(end)];  %Array of suspected peaks given in sample numbers. Treated as a queue
peaksFinal = [];

ekg = zeroOut(ekg, peaks, below, above, srate); %Zero out the signal around suspected peaks

while (length(peaks) > 1) %Loop while suspeced peaks exist
   innerBeat = getRefinement(peaks(1), peaks(2));
    %See if there are more peaks between suspected peaks
   if isempty(innerBeat) %No new peaks exists between the first and last beat
       peaksFinal = [peaksFinal, peaks(1)]; %Add firstBeat to the final list
	   peaks = peaks(2:end); %Make t2 the new start of the suspected peaks list
   else
       peaks = [peaks(1) innerBeat peaks(2:end)]; %tb is a suspected peak. Add it to the list
   end
end



    function innerBeat = getRefinement(firstBeat, lastBeat)
    %% Find a beat peak between two existing beats if it exists
    %
    % Parameters:
    %   firstBeat The beat farthest to the left. 
    %   lastBeat  The beat farthest to the right.
    %   innerBeat (output) is the location of the inner beat...empty
    %   
    %   Example:
    %       innerBeat = getRefinement(firstBeat, lastBeat)
    %%
        innerBeat = [];
        if lastBeat - firstBeat < maxDist %IBI < maxDist (1.5 s)
            return;
        end
        thisSignal = ekg(firstBeat:lastBeat);
        %Find the maximum between two known peaks
            [~,innerBeat] = max(thisSignal); %index of the max from first beat
            if notFeasible(firstBeat, innerBeat, lastBeat) %Not a valid peak
               innerBeat = innerBeat + firstBeat - 1;
%                lowerPoint = max(firstBeat, innerBeat-minDist);
%                highPoint = max(firstBeat, innerBeat+minDist);
%                ekg(lowerPoint:highPoint) = 0;              
                ekg = zeroOut(ekg, innerBeat, below, above, srate);
            else %Valid peak
               innerBeat = innerBeat + firstBeat - 1; 
               ekg = zeroOut(ekg, innerBeat, below, above, srate);
               return;
            end
    end	

    function ekg = zeroOut(ekg, peaks, below, above, srate)
     %% Zero out the surrounding signal around suspected R peaks.
     %
     %  Parameters:
     %      ekg    The EKG signal prior to zeroing out.
     %      peaks  An array of suspected R peaks in samples.
     %      below  The minimum time allowed between consecutive R peaks
     %             in seconds.
     %      above  The maximum time allowed between consecutive R peaks in
     %              seconds.
     %      srate  The sampling rate of the signal used to convert time to
     %              sample numbers.
     %      ekg    (output) The EKG signal that has been zeroed out around
     %             the R peaks.
     %
     %  Example:
     %      ekg = zeroOut(ekg, peaks, below, above, srate)
     %%
        belowSamples = round(below*srate); %Below time in samples
        aboveSamples = round(above*srate); %Above time in samples
        for k = 1:length(peaks) %Zero out area around peaks
           firstSample = max(1, peaks(k) - eps); %Max between 1 and tb-below
           lastSample = min(peaks(k) + eps, length(ekg)); %Min between tb+above and length of ekg
           ekg(firstSample: lastSample) = 0;
        end
        
        
    end

    function result = notFeasible(firstBeat, innerBeat, lastBeat)
    %% Determine if the innerbeat meets the criteria for an R peak.
    % 
    % notFeasible determines if innerBeat meets the criteria for being an R
    %   peak. Inner beat's R and S peaks must above the upper threshold and 
    %   below the lower threshold respectively and has to be a minimum of minDist
    %   away from the firstBeat and lastBeat and a maximum of maxDist away from 
    %   firstBeat and lastBeat.
    %
    % Parameters:
    %   firstBeat   The beat farthest to the left.
    %   innerBeat   The suspected beat between firstBeat and lastBeat.
    %   lastBeat    The beat farthest to the right. 
    %   result      (output) Logical 1 or 0 depending if the innerBeat
    %               meets the criteria to be an R peak. 
    %
    %   Example:
    %       result = notFeasible(firstBeat, innerBeat, lastBeat)
    %%
        
        % innerBeat is either the firstBeat or lastBeat. 
        if innerBeat == 1 || innerBeat == (lastBeat-firstBeat+1)
            result = 1;
            return;
        end
    
        negSignal = -ekg(innerBeat+firstBeat-1:lastBeat);
  
        negTime = 1:length(negSignal);
        [sVal,sLocs,~,~] = findpeaks(double(negSignal), negTime,...
                        'MinPeakHeight', -lowerThreshold);
        [~,index] = min(abs(sLocs-innerBeat));
        upperPeak = ekg(firstBeat+innerBeat-1);
        lowerPeak = sVal(index);
        
        if isempty(index) % Error detecting peak
            result = 1;
            return;
        end

           if (firstBeat + minDist < innerBeat+firstBeat-1) && ...
                   (lastBeat - minDist > innerBeat+firstBeat-1) %tb is at least the minimum distance away from t1 and t2
               %Threshold check,         
               if (upperPeak > upperThreshold) && (-lowerPeak < lowerThreshold)
                    if length(index) == 1
                        if index < 20 
                            result = 0;
                        else
                            result = 1;
                        end
                    else
                        result = 1;
                    end
               else
                   result = 1;
               end
           else
              result = 1; 
           end      
 
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
            if i == 1
                thisSignal = signal(1:thisIdx);
            end
            if i == (length(index)+1)
                thisIdx = index(end);
                thisSignal = signal(thisIdx:end);
            end
            if ~(i==1) && ~(i==(length(index)+1))
                thisIdx = index(i);
                thisSignal = signal(index(i-1):thisIdx);
            end
            yValue = max(thisSignal);
            if yValue > 100
                maxValues(b) = yValue;
                b = b + 1;
            end
        end
        
        if ~isrow(maxValues)
            maxValues = maxValues';
        end
        idx = ismember(signal', maxValues);
    end

end 