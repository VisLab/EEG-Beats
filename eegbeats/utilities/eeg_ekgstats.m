function ibiInfo = eeg_ekgstats(ekgPeaks, params)

    [~, ibiInfo, ibiMeasures] = getEmptyBeatStructs();
    ibiInfo.fileName = ekgPeaks.fileName;
    ekg = ekgPeaks.ekg;
    srate = ekgPeaks.srate;
    ekgMins = length(ekg)/60.0/srate;
    peakFrames = ekgPeaks.peakFrames;
    ibiInfo.fileMins = ekgMins;
    ibiInfo.blockMins = min(ekgMins, params.ibiBlockMins);
    
    ibiInfo.overallMeasures = ...
        getIBIMeasures(peakFrames, ibiInfo.blockMins, params);
    if ekgMins <= params.ibiBlockMins
        return;
    end
    ibiInfo.blockStepMins = min(ekgMins, params.ibiBlockStepMins);
    numBlocks = floor((ekgMins - ibiInfo.blockMins)/ibiInfo.blockStepMins)+ 1;
    blockM = ibiMeasures;
    blockM(numBlocks) = blockM(1);
    startFrame = 1;
    blockFrames = round(ibiInfo.blockMins*60*srate);
    blockStep = round(ibiInfo.blockStepMins*60*srate);
    for n = 1:numBlocks
        endFrame = startFrame + blockFrames - 1;
        thesePeaks = peakFrames(startFrame <= peakFrames & peakFrames <= endFrame);
        blockM(n) = getIBIMeasures(thesePeaks, ibiInfo.blockMins, params);
        blockM(n).startMins = (startFrame - 1)/60/srate;
        startFrame = startFrame + blockStep;
    end
    ibiInfo.blockMeasures = blockM;