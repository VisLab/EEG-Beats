%function [pSpectrum, f] = getARSpectrum(RRs, frames, params)
ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_14\ekgPeaks.mat';

temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
peakFrames = ekgPeaks(1).peakFrames;
params = temp.params;
numFiles = length(ekgPeaks);
srate = ekgPeaks(1).srate;
RRs = 1000*(peakFrames(2:end) - peakFrames(1:end-1))/srate;
frames = peakFrames(2:end);

fs = 1000./mean(RRs);
ts = frames/srate;
x = detrend(RRs, 5, 'SamplePoints', ts);

  
% [p, f] = pburg(x, 16, [], fs);
% n = length(x);
% aic = zeros(25, 1);
% for k = 5:25
%     [a, sse] = arburg(x, k);
%     aic(k) = n * log(sse) + 2 * k;
% end
% [~, ia] = max(aic);
% [p1, f1] = pburg(x, ia, [], fs);
% 
% figure('Name', 'AIC')
% plot(aic)
% 
% figure
% hold on
% plot(f, p, '-k')
% plot(f1, p1, '-g')
% 
% [~, s] = max(p);
% [~, s1] = max(p1);
% legend(['p=' num2str(16)], ['p=' num2str(ia)])
% hold off
% fprintf('%d: peak %g %d: peak %g', 16, f(s), ia, f(s1))
xq = linspace(frames(1), frames(end), 2*length(x));
vq = interp1(frames,x,xq, 'spline');
figure('Name', 'Interpolation')
hold on
plot(ts, x, '-k')
plot(xq/srate, vq, '-r')

x = vq;
ts = xq/srate;
fs = 1/(ts(2) - ts(1));

[p, f] = pwelch(x,[],[],256,fs);

figure

plot(f, p, '-k')

[~, s] = max(p);

fprintf(' peak  freq %g\n', f(s)/2)

