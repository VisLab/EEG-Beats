    function valid = determineIfTwoSidedPeak(ekg, beatFrame, params)
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
        qrsFrames = round(params.qrsDuration*params.srate);
        startFrame = max(1, beatFrame - qrsFrames);
        endFrame = min(length(ekg), beatFrame + qrsFrames);
        maskLeft = ekg(startFrame: beatFrame - 1) <= params.baseThreshold;
        maskRight = ekg(beatFrame + 1:endFrame) <= params.baseThreshold;
        upperThreshold = median(ekg) + (params.stdThreshold*1.4826*mad(ekg,1));     
        valid = (ekg(beatFrame) > upperThreshold) && sum(maskLeft) > 0 && sum(maskRight) > 0;
    end
