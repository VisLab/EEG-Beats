function [pSpectrum, f] = getSpectrum(RRs, ts, params)

    sType = params.spectrumType;
    if strcmpi(sType, 'ar')
        [pSpectrum, f, modelOrder] = getAR(RRs, params);
    elseif strcmpi(sType, 'fft')
        [pSpectrum, f] = getWelch(RRs, ts, params);
    else
        [pSpectrum, f] = plomb(RRs, ts, params.freqCutoff);
    end
end

function [pSpectrum, f] = getAR(RRs, params)
    fs = params.freqCutoff;
    aic = zeros(1, params.arMaxModelOrder);
    n = length(RRs);
    for k = 5:params.arMaxModelOrder
        [~, sse] = arburg(RRs, k);
        aic(k) = n * log(sse) + 2 * k;
    end
    [~, ia] = max(aic);
    [pSpectrum, f] = pburg(x, ia, [], fs);
end

function [pSpectrum, f] = getWelch(RRs, ts, params)
    xq = linspace(frames(1), frames(end), 2*length(x));
    vq = interp1(frames,x,xq, 'spline');


    x = vq;
    ts = xq/srate;
    fs = 1/(ts(2) - ts(1));

    [pSpectrum, f] = pwelch(x,[],[],256,fs);
end
