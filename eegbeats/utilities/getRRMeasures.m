function rrMeasures = getRRMeasures(peakFrames, blockMinutes, params)
%% Given a specific list of peak frames generate RR measures
% Parameters:
%    peakFrames     array of frame (sample) numbers for peak locations
%    blockMinutes   total length in minutes of data represented peakFrames
%    params         parameter structure
%    rrMeasures     (output) an rrMeasures structure
%
% Notes:  See getEmptyBeatStructs for form of rrMeasures.
%%
    [~, ~, rrMeasures] = getEmptyBeatStructs();
    if isempty(peakFrames)
        warning('Failed because no peak frames');
        return;
    end
    rrMeasures.startMinutes = 0;
    rrMeasures.blockMinutes = blockMinutes;
    rrMeasures.meanHR = length(peakFrames)./blockMinutes;
    RRs = 1000*(peakFrames(2:end) - peakFrames(1:end-1))/params.srate;
    frames = peakFrames(2:end);
    
    %% See if we should remove out of range RRs
    if params.removeOutOfRangeRRs
        badRRMask = RRs < params.rrMinMs | RRs > params.rrMaxMs;
        RRs = RRs(~badRRMask);
        frames = frames(~badRRMask);
        rrMeasures.numBadRRs = sum(badRRMask);
    else
        rrMeasures.numBadRRs = 0;
    end
    
    
    rrMeasures.numRRs = length(RRs);
    rrMeasures.meanRR = mean(RRs);
    rrMeasures.medianRR = median(RRs);
    rrMeasures.skewRR = skewness(RRs);
    rrMeasures.kurtosisRR = kurtosis(RRs);
    rrMeasures.iqrRR = iqr(RRs);

    rrMeasures.SDNN = std(RRs);
    RRDiffs = abs(RRs(2:end) - RRs(1:end-1));
    rrMeasures.SDSD = std(RRDiffs);
    rrMeasures.RMSSD = sqrt(mean(RRDiffs.*RRDiffs));
    rrMeasures.NN50 = sum(RRDiffs > 50);
    rrMeasures.pNN50 = rrMeasures.NN50/length(RRDiffs);
    
    %% Should we remove the trend before doing spectral measures
    ts = (frames - 1)/params.srate;
    if (params.detrendOrder > 0)
        dRRs = detrend(RRs, params.detrendOrder, 'SamplePoints', ts);
        zdiff = RRs - dRRs;
        rrMeasures.trendSlope = (zdiff(2) - zdiff(1))/ts(2) - ts(1);
        RRs = dRRs;
    end
    
    %% Now compute frequency measures
    [pSpectrum, f] = getSpectrum(RRs, ts, params);
    rrMeasures.spectrumType = params.spectrumType;
    deltaF = f(2)-f(1);
    rrMeasures.totalPower = 0.5*(2*sum(pSpectrum) - pSpectrum(1) - pSpectrum(end))*deltaF;

    VLF = pSpectrum(params.VLFRange(1) < f & f <= params.VLFRange(2));
    LF = pSpectrum(params.LFRange(1) < f & f <= params.LFRange(2));
    HF = pSpectrum(params.HFRange(1) < f & f <= params.HFRange(2));
    rrMeasures.VLF = 0.5*(2*sum(VLF) - VLF(1) - VLF(end))*deltaF;
    rrMeasures.LF = 0.5*(2*sum(LF) - LF(1) - LF(end))*deltaF;
    rrMeasures.LFnu = 100*rrMeasures.LF/(rrMeasures.totalPower - rrMeasures.VLF);
    rrMeasures.HF = 0.5*(2*sum(HF) - HF(1) - HF(end))*deltaF;

    rrMeasures.HFnu = 100*rrMeasures.HF/(rrMeasures.totalPower - rrMeasures.VLF);
    rrMeasures.LFHFRatio = rrMeasures.LF/rrMeasures.HF;
    rrMeasures.PSD = pSpectrum;
    rrMeasures.F = f;

end