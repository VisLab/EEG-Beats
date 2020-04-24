function [beatValue, troughValue] = getBeatValue(signal, beatFrame, qrsFrames, threshold, singlePeak)

    if singlePeak
        beatValue = getTwoSidedValue(signal, beatFrame, threshold, qrsFrames);
        troughValue = [];
    else
        rightPart = round(beatFrame:min(beatFrame + 2*qrsFrames, length(signal)));
        [beatValue, troughValue] = determineIfPeakHasTrough(signal(rightPart), threshold, qrsFrames);
    end
end
    
       function beatValue = getTwoSidedValue(ekg, beatFrame, qrsFrames, threshold)
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
        maskLeft = ekg(round(max(1, beatFrame - qrsFrames) :(beatFrame - 1))) <= 0;
        maskRight = ekg(round((beatFrame + 1):min(beatFrame + qrsFrames, length(ekg)))) <= 0;
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