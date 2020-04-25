function ibiMeasures = getIBIMeasures(peakFrames, blockMins, params)
%% Given a specific ibi generate the indicators
% Parameters:
%       the ibi signal
% Return value:
%       the different statistical indicators as a list of size 6
%       containing the following in order:
%           mean std rmssd nn50
%           pnn50 rrt
%%
    [~, ~, ibiMeasures] = getEmptyBeatStructs();
    ibiMeasures.startMins = 0;
    ibiMeasures.blockMins = blockMins;
    ibiMeasures.meanHR = length(peakFrames)./blockMins;
    ibis = 1000*(peakFrames(2:end) - peakFrames(1:end-1))/params.srate;
    badIBIMask = ibis < params.ibiMinMs | ibis > params.ibiMaxMs;
    frames = peakFrames(1:end-1);
    ibis = ibis(~badIBIMask);
    ibiMeasures.numIBIs = length(ibis);
    frames = frames(~badIBIMask);
    ibiMeasures.meanIBI = mean(ibis);
    ibiMeasures.medianIBI = median(ibis);
    ibiMeasures.sdnn = std(ibis);
    ibiDiffs = ibis(2:end) - ibis(1:end-1);
    ibiMeasures.sdsd = std(ibiDiffs);
    ibiMeasures.rmsdd = sqrt(mean(ibiDiffs.*ibiDiffs));
    ibiMeasures.nn50 = sum(ibiDiffs > 50);
    ibiMeasures.pnn50 = 100*ibiMeasures.nn50/length(ibiDiffs);
    
end