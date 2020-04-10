    function tVal = determineIfTwoSidedPeak(ekg, beatFrame, qrsFrames, threshold)
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
        maskRight = ekg(round((beatFrame + 1):min(beatFrame + 2*qrsFrames, length(ekg)))) <= 0;
        valid = (ekg(beatFrame) > threshold) && sum(maskLeft) > 0 && sum(maskRight) > 0;
        if valid
            tVal = ekg(beatFrame);
        else
            tVal = [];
        end
    end
