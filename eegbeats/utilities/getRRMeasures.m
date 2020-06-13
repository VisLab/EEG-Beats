function RRMeasures = getRRMeasures(peakFrames, blockMinutes, params)
%% Given a specific ibi generate the indicators
% Parameters:
%       the ibi signal
% Return value:
%       the different statistical indicators as a list of size 6
%       containing the following in order:
%           mean std rmssd nn50
%           pnn50 rrt
%%
    [~, ~, RRMeasures] = getEmptyBeatStructs();
    if isempty(peakFrames)
        warning('Failed because no peak frames');
        return;
    end
    RRMeasures.startMinutes = 0;
    RRMeasures.blockMinutes = blockMinutes;
    RRMeasures.meanHR = length(peakFrames)./blockMinutes;
    RRs = 1000*(peakFrames(2:end) - peakFrames(1:end-1))/params.srate;
    frames = peakFrames(2:end);
    
    %% See if we should remove out of range RRs
    if params.removeOutOfRangeRRs
        badRRMask = RRs < params.rrMinMs | RRs > params.rrMaxMs;
        RRs = RRs(~badRRMask);
        frames = frames(~badRRMask);
        RRMeasures.numBadRRs = sum(badRRMask);
    else
        RRMeasures.numBadRRs = 0;
    end
    
    
    RRMeasures.numRRs = length(RRs);
    RRMeasures.meanRR = mean(RRs);
    RRMeasures.medianRR = median(RRs);
    RRMeasures.skewRR = skewness(RRs);
    RRMeasures.kurtosisRR = kurtosis(RRs);
    RRMeasures.iqrRR = iqr(RRs);

    RRMeasures.SDNN = std(RRs);
    RRDiffs = abs(RRs(2:end) - RRs(1:end-1));
    RRMeasures.SDSD = std(RRDiffs);
    RRMeasures.RMSSD = sqrt(mean(RRDiffs.*RRDiffs));
    RRMeasures.NN50 = sum(RRDiffs > 50);
    RRMeasures.pNN50 = 100*RRMeasures.NN50/length(RRDiffs);
    
    %% Should we remove the trend before doing spectral measures
    ts = (frames - 1)/params.srate;
    if (params.detrendOrder > 0)
        dRRs = detrend(RRs, params.detrendOrder, 'SamplePoints', ts);
        zdiff = RRs - dRRs;
        RRMeasures.trendSlope = (zdiff(2) - zdiff(1))/ts(2) - ts(1);
        RRs = dRRs;
    end
    
    %% Now compute frequency measures
    [pSpectrum, f] = getSpectrum(RRs, ts, params);
    RRMeasures.spectrumType = params.spectrumType;
    deltaF = f(2)-f(1);
    RRMeasures.totalPower = 0.5*(2*sum(pSpectrum) - pSpectrum(1) - pSpectrum(end))*deltaF;

    VLF = pSpectrum(params.VLFRange(1) < f & f <= params.VLFRange(2));
    LF = pSpectrum(params.LFRange(1) < f & f <= params.LFRange(2));
    HF = pSpectrum(params.HFRange(1) < f & f <= params.HFRange(2));
    RRMeasures.VLF = 0.5*(2*sum(VLF) - VLF(1) - VLF(end))*deltaF;
    RRMeasures.LF = 0.5*(2*sum(LF) - LF(1) - LF(end))*deltaF;
    RRMeasures.LFnu = 100*RRMeasures.LF/(RRMeasures.totalPower - RRMeasures.VLF);
    RRMeasures.HF = 0.5*(2*sum(HF) - HF(1) - HF(end))*deltaF;

    RRMeasures.HFnu = 100*RRMeasures.HF/(RRMeasures.totalPower - RRMeasures.VLF);
    RRMeasures.LFHFRatio = RRMeasures.LF/RRMeasures.HF;
    RRMeasures.PSD = pSpectrum;
    RRMeasures.F = f;

end