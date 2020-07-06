function [rrInfo, params] = eeg_ekgstats(ekgPeaks, params)
% Compute the rrInfo structure from the ekgPeaks structure

%% Check the parameters
    [params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
    if ~isempty(errors)
        error(['eeg_ekgstats has invalid input parameters' cell2str(errors)]);
    end

%% Get the empty structures an fill in basic information
    [~, rrInfo, RRMeasures] = getEmptyBeatStructs();
    rrInfo.fileName = ekgPeaks.fileName;
  
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
    rrInfo.fileMinutes = ekgMinutes;
    rrInfo.blockMinutes = min(ekgMinutes, params.rrBlockMinutes);

%% Remove out-of-range peaks identified in eegPeaks
   if (params.removeOutOfRangePeaks)
       peakFrames = setdiff(peakFrames, ekgPeaks.lowAmplitudePeaks);
       peakFrames = setdiff(peakFrames, ekgPeaks.highAmplitudePeaks);
   end
 
%% Compute the overall and block measures
    rrInfo.overallValues = getRRMeasures(peakFrames, rrInfo.fileMinutes, params);
    rrInfo.blockStepMinutes = min(ekgMinutes, params.rrBlockStepMinutes);
    numBlocks = floor((ekgMinutes - rrInfo.blockMinutes)/rrInfo.blockStepMinutes)+ 1;
    blockM = RRMeasures;
    blockM(numBlocks) = blockM(1);
    startFrame = 1;
    blockFrames = round(rrInfo.blockMinutes*60*srate);
    blockStep = round(rrInfo.blockStepMinutes*60*srate);
    for n = 1:numBlocks
        endFrame = startFrame + blockFrames - 1;
        thesePeaks = peakFrames(startFrame <= peakFrames & ...
                     peakFrames <= endFrame);
        blockM(n) = getRRMeasures(thesePeaks, rrInfo.blockMinutes, params);
        blockM(n).startMinutes = (startFrame - 1)/60/srate;
        startFrame = startFrame + blockStep;
    end
    rrInfo.blockValues = blockM;