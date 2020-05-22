function maxFrames = initialParseRR(signal, consensusIntervals, minRRFrames)
%% Find a small number of suspected R peaks in the ekg as fenceposts
%
%   Parameters: 
%       signal     EKG signal oriented to be upward
%       params     params structure
%       maxFrames (output)Array of indices of suspected peaks
%%  
    boxSize = floor(length(signal)/consensusIntervals);
    eSignal = zeros(boxSize*consensusIntervals, 1);
    eSignal = signal(1:length(eSignal));
    eSignal = reshape(eSignal, boxSize, consensusIntervals);
    [~, maxFrames] = max(eSignal, [], 1);
    frameIncrement = ((1:consensusIntervals) - 1)* boxSize;
    maxFrames = maxFrames + frameIncrement;
    diffMask = (maxFrames(2:end) - maxFrames(1:end - 1)) < minRRFrames;
    maxFrames([false, diffMask]) = [];
end
