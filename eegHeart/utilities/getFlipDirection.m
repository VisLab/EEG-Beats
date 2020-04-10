function flip = getFlipDirection(ekg, framesPerInterval, threshold)
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
    flipMarkers = zeros(numIntervals, 1);
    for k = 1:numIntervals
        flipMarkers(k) = determineIfFlip(ekg(startFrames(k):endFrames(k)), threshold);
    end
    flips = sum(flipMarkers == 1);
    noFlips = sum(flipMarkers == 0);
    if flips == 0 && noFlips == 0
        warning('getConsensusDirection can not determine a conensus direction peak threshold may be too high')
        flip = -1;
    else
        flip = flips > noFlips;
    end
end


function flip = determineIfFlip(ekgInterval, threshold)
%% Determine whether biggest peak is up or down or not valid
%
% Parameters: 
%   ekg      ekg signal
%   flip     0 indicates no flip, 1 indicates flip, -1 indicates no peaks
%
    maxEkg = abs(max(ekgInterval));
    minEkg = abs(min(ekgInterval));
   
    if maxEkg < minEkg && minEkg > threshold
        flip = 1;
    elseif minEkg < maxEkg && maxEkg > threshold
        flip = 0;
    else
        flip = -1;
    end
end

