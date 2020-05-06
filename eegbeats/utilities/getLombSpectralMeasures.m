function sMeasures = getLombSpectralMeasures(RRs, frames, params)
%% Compute power spectral measures using 
    [~, ~, ~, sMeasures] = getEmptyBeatStructs();
    sMeasures.sType = 'lomb';
    ts = frames/params.srate;
    [pSpectrum, f] = plomb(RRs, ts, params.freqCutoff);
    deltaF = f(2)-f(1);
    sMeasures.totalPower = 0.5*(2*sum(pSpectrum) - pSpectrum(1) - pSpectrum(end))*deltaF;

    VLF = pSpectrum(params.VLFRange(1) < f & f <= params.VLFRange(2));
    LF = pSpectrum(params.LFRange(1) < f & f <= params.LFRange(2));
    HF = pSpectrum(params.HFRange(1) < f & f <= params.HFRange(2));
    sMeasures.VLF = 0.5*(2*sum(VLF) - VLF(1) - VLF(end))*deltaF;
    sMeasures.LF = 0.5*(2*sum(LF) - LF(1) - LF(end))*deltaF;
    sMeasures.LFnu = 100*sMeasures.LF/(sMeasures.totalPower - sMeasures.VLF);
    sMeasures.HF = 0.5*(2*sum(HF) - HF(1) - HF(end))*deltaF;

    sMeasures.HFnu = 100*sMeasures.HF/(sMeasures.totalPower - sMeasures.VLF);
    sMeasures.LFHFRatio = sMeasures.LF/sMeasures.HF;
    sMeasures.PSD = pSpectrum;
    sMeasures.F = f;