function [beatValue, troughValue] = getBeatValue(signal, beatFrame, qrsHalfFrames, threshold, singlePeak)
%% Return proper position of peak frame if valid peak, otherwise return empty
%
%  Parameters:
%    signal         1-D ekg signal
%    beatFrame      frame position of the potential peak
%    qrsHalfFrames  maximum half-width of valid peaks
%    threshold      minimum amplitude of valid peaks
%    singlePeak     if false, assume it is a peak with following trough
%
%% Compute the correct peak position if a valid peak
    if singlePeak
        beatValue = getTwoSidedValue(signal, beatFrame, threshold, qrsHalfFrames);
        troughValue = [];
    else
        rightPart = round(beatFrame:min(beatFrame + 2*qrsHalfFrames, length(signal)));
        [beatValue, troughValue] = determineIfPeakHasTrough(signal(rightPart), threshold, qrsHalfFrames);
    end
end
    
       function beatValue = getTwoSidedValue(ekg, beatFrame, qrsHalfFrames, threshold)
        %% Determine if the value at the peak is actually a peak
        % 
        % Parameters:
        %    beatIdx            The index of the peak
        %    startIdx           The start index of the interval
        %    endIdx             The end indexof the interval
        %  Result: 
        %    result             Indicator is peak if valid
        %                           1 = validPeak,0 = invalidPeak
        %
        %%
        maskLeft = ekg(round(max(1, beatFrame - qrsHalfFrames):(beatFrame - 1))) <= 0;
        maskRight = ekg(round((beatFrame + 1):min(beatFrame + qrsHalfFrames, length(ekg)))) <= 0;
        valid = (ekg(beatFrame) > threshold) && sum(maskLeft) > 0 && sum(maskRight) > 0;
        if valid
            beatValue = ekg(beatFrame);
        else
            beatValue = [];
        end
       end
    
       function [beatValue, troughValue] = determineIfPeakHasTrough(rightPart, qrsFrames, threshold)
        %%
        % Determine if the value at the peak is actually a peak.
        % Parameters:
        %    beatIdx   the index of the peak
        %%
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        beatValue = [];
        troughValue = [];
        if length(rightPart) <= 3
            return;
        end
        [tVal, tLocs] = findpeaks(-rightPart(2:end), 'SortStr', 'descend');
        if ~isempty(tLocs) && tVal(1) > threshold && tLocs(1) < qrsFrames
            beatValue = rightPart(1);
            troughValue = -tVal(1);
        end
       end