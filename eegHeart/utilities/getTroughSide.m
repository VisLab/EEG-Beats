function rightSide = getTroughSide(ekg, framesPerInterval, qrsFrames, threshold)
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
% Get starting frames for generating consensus
    numIntervals = floor(length(ekg)/framesPerInterval);
    startFrames = (0:(numIntervals - 1))'*framesPerInterval + 1;
    endFrames = startFrames + framesPerInterval - 1;
    ekglr = fliplr(ekg);
    totalFrames = length(ekg);
    sideMarkers = -ones(numIntervals, 1);
    for k = 1:numIntervals
        ekgInterval = ekg(startFrames(k):endFrames(k));
        [beatValue, beatFrame] = max(ekgInterval);
        if beatValue < threshold
            continue;
        end
        beatRight = startFrames(k) + beatFrame - 1;
        [~, rtVal] = getBeatValue(ekg, beatRight, threshold,  qrsFrames, false);
        beatLeft = totalFrames - beatRight + 1;
        [~, ltVal] = getBeatValue(ekglr, beatLeft, threshold, qrsFrames, false);
        if isempty(ltVal) && isempty(rtVal)
            continue;
        elseif isempty(ltVal) && ~isempty(rtVal)
            sideMarkers(k) = 1;
        elseif isempty(rtVal) && ~isempty(ltVal)
            sideMarkers(k) = 0;
        elseif rtVal < ltVal
            sideMarkers(k) = 1;
        else
            sideMarkers(k) = 0;
        end
    end
    rightSides = sum(sideMarkers == 1);
    leftSides = sum(sideMarkers == 0);
    if rightSides == 0 && leftSides == 0
        warning('getTroughSide does not have many troughs')
        rightSide = -1;
    else
        rightSide = rightSides > leftSides;
    end
end
