function rrMeasures = getRRMeasures(RRs, blockMinutes, params)
%% Given a specific list of RR
% Parameters:
%    RRs            nn x 2 array with positions in frames and values of RRs
%    blockMinutes   total length in minutes of data represented peakFrames
%    params         parameter structure
%    rrMeasures     (output) an rrMeasures structure
%
% Notes:  See getEmptyBeatStructs for form of rrMeasures.
%%

    [~, ~, rrMeasures] = getEmptyBeatStructs();
    if size(RRs, 1) < 2
        warning('%s: Must have at least 2 RR values to compute measures', params.fileName);
        return;
    end
    rrMeasures.startMinutes = 0;
    rrMeasures.totalRRs = size(RRs, 1);
    rrMeasures.meanHR = (rrMeasures.totalRRs + 1)./blockMinutes;
    ts = (RRs(:, 1) - 1)/params.srate;
    rrMeasures.numRRs = size(RRs, 1);
    rrMeasures.meanRR = mean(RRs(:, 2));
    rrMeasures.medianRR = median(RRs(:, 2));
    rrMeasures.skewRR = skewness(RRs(:, 2));
    rrMeasures.kurtosisRR = kurtosis(RRs(:, 2));
    rrMeasures.iqrRR = iqr(RRs(:, 2));

    rrMeasures.SDNN = std(RRs(:, 2));
    RRDiffs = abs(RRs(2:end, 2) - RRs(1:end-1, 2));
    rrMeasures.SDSD = std(RRDiffs);
    rrMeasures.RMSSD = sqrt(mean(RRDiffs.*RRDiffs));
    rrMeasures.NN50 = sum(RRDiffs > 50);
    rrMeasures.pNN50 = rrMeasures.NN50/length(RRDiffs);
    
    %% Should we remove the trend before doing spectral measures
    dRRs = RRs(:, 2);
    if (params.detrendOrder > 0)
        dRRs = detrend(RRs(:, 2), params.detrendOrder, 'SamplePoints', ts);
        zdiff = RRs(:, 2) - dRRs;
        rrMeasures.trendSlope = (zdiff(2) - zdiff(1))/ts(2) - ts(1);
    end
    
    %% Now compute frequency measures
    [pSpectrum, f] = getSpectrum(dRRs, ts, params);
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