function RRInfo = eeg_ekgstats(ekgPeaks, params)

    [~, RRInfo, RRMeasures] = getEmptyBeatStructs();
    RRInfo.fileName = ekgPeaks.fileName;
  
    ekg = ekgPeaks.ekg;
    if isempty(ekgPeaks.ekg) || ...
      ((length(ekgPeaks.ekg) <= 1) && isnan(ekgPeaks.ekg)) || ...
      isempty(ekgPeaks.peakFrames) || ....
      ((length(ekgPeaks.peakFrames) <= 1) && isnan(ekgPeaks.peakFrames))
      return;
    end
    srate = ekgPeaks.srate;
    ekgMinutes = length(ekg)/60.0/srate;
    peakFrames = ekgPeaks.peakFrames;
    RRInfo.fileMinutes = ekgMinutes;
    RRInfo.blockMinutes = min(ekgMinutes, params.RRBlockMinutes);
    
    RRInfo.overallValues = getRRMeasures(peakFrames, RRInfo.fileMinutes, params);
    RRInfo.blockStepMinutes = min(ekgMinutes, params.RRBlockStepMinutes);
    numBlocks = floor((ekgMinutes - RRInfo.blockMinutes)/RRInfo.blockStepMinutes)+ 1;
    blockM = RRMeasures;
    blockM(numBlocks) = blockM(1);
    startFrame = 1;
    blockFrames = round(RRInfo.blockMinutes*60*srate);
    blockStep = round(RRInfo.blockStepMinutes*60*srate);
    for n = 1:numBlocks
        endFrame = startFrame + blockFrames - 1;
        thesePeaks = peakFrames(startFrame <= peakFrames & peakFrames <= endFrame);
        blockM(n) = getRRMeasures(thesePeaks, RRInfo.blockMinutes, params);
        blockM(n).startMinutes = (startFrame - 1)/60/srate;
        startFrame = startFrame + blockStep;
    end
    RRInfo.blockValues = blockM;