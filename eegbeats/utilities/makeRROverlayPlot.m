function hFig = makeRROverlayPlot(ekgPeaks, params)   
%% Shows EEG overlaid with RRs and ones that are assigned as out-of-range

hFig = [];
ekg = ekgPeaks.ekg;
if isempty(ekg) || (isscalar(ekg) && isnan(ekg))
    warning('%s: does not have any ekg', params.fileName);
    return;
end
peakFrames = ekgPeaks.peakFrames;
if isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
    warning('%s: does not have any heart beats', params.fileName);
    return;
end

%% Get the RRs and the masks
lowAmpPeaks = ekgPeaks.lowAmplitudePeaks; 
highAmpPeaks = ekgPeaks.highAmplitudePeaks;
[allRRs, masks, maskTypes] = getRRsFromPeaks(peakFrames, lowAmpPeaks, highAmpPeaks, params); 
outOfRangeRRMask = masks(:, strcmpi(maskTypes, 'LowRR')) | ...
    masks(:, strcmpi(maskTypes, 'HighRR'));
outOfRangePeakRRMask = masks(:, strcmpi(maskTypes, 'LowAmpRR')) | ...
    masks(:, strcmpi(maskTypes, 'HighAmpRR'));
neighborRRMask = masks(:, strcmpi(maskTypes, 'BadNeighborRR'));

%% Clip the EEG if necessary
peakPrts = prctile(ekg(peakFrames), [25, 50, 75]);
basePoint = max(abs(peakPrts));
extremeLim = basePoint + abs(peakPrts(3) - peakPrts(1));
ekg(ekg < -extremeLim) = -extremeLim;
ekg(ekg > extremeLim) = extremeLim;

%% Now do the plot
hFig = figure('Visible', params.figureVisibility);
seconds = (0:(length(ekg) - 1))./params.srate;
rrTimes = (allRRs(:, 1) - 1)./params.srate;

%% Plot the EKG and peaks
%[0 0.4470 0.7410] [0.8500 0.3250 0.0980]
yyaxis left
Lekg = plot(seconds, ekg, 'Color', [0.8, 0.8, 0.8], 'LineStyle', '-');
hold on
Lpeaks = plot(seconds(peakFrames), ekg(peakFrames), 'LineStyle', 'None', ...
    'Color', [0.6500 0.5250 0.2980], 'MarkerSize', 10, 'Marker', '*');
set(gca, 'YColor', [0.6500 0.5250 0.2980]);
ylabel('EKG signal', 'Color', [0.6500 0.5250 0.2980])
xlabel('Seconds')
xLims = get(gca, 'XLim');
Laxis = line(xLims, [0, 0], 'Color', [0.6500 0.5250 0.2980]);
legendString = {'EEG', 'Peaks', 'EEG axis'};
%legend(gca, legendStringLeft, 'Location', 'southeastoutside', 'Orientation', 'Horizontal')
hold off

yyaxis right
hold on
Lrrs = plot(rrTimes, allRRs(:, 2), 'sk', 'MarkerSize', 12, 'LineWidth', 1);
legendString{end + 1} = 'RRs';
medianRR = median(allRRs(:, 2));
LrrMeds = line(gca, xLims, [medianRR, medianRR], ...
             'Color', [0.4660, 0.6740, 0.1880], 'LineWidth', 2);
legendString{end + 1} = 'RR median';
legendObjs = [Lekg, Lpeaks, Laxis, Lrrs, LrrMeds];

if sum(neighborRRMask) > 0
    LNeigh = plot(rrTimes(neighborRRMask), allRRs(neighborRRMask, 2),  ...
        'Color', [0.4660, 0.6740, 0.1880], 'Marker','x', ...
        'LineWidth', 2, 'MarkerSize', 12, 'LineStyle', 'None');
    legendString{end + 1} = 'Bad neighbor';
    legendObjs(end + 1) = LNeigh;
end

if sum(outOfRangePeakRRMask) > 0
    LRange = plot(rrTimes(outOfRangePeakRRMask), allRRs(outOfRangePeakRRMask, 2),  ...
        'o', 'LineWidth', 2, 'MarkerSize', 14, ...
        'Color', [0, 0.4470, 0.7410], 'LineStyle', 'None');
    legendString{end + 1} = 'Outlier peak RRs';
    legendObjs(end + 1) = LRange;
end

set(gca, 'YLim', [500, 1500], 'YColor', [0, 0, 0]);
set(hFig, 'position', [0 0 2000 500])
baseTitle = ['Peaks:' num2str(length(ekgPeaks)) ...
    ' Low peaks:' num2str(length(lowAmpPeaks)) ...
    ' High peaks:' num2str(length(highAmpPeaks)) ...
    ' Bad neighbor RRs:' num2str(sum(neighborRRMask)) ...
    ' RRs around outlier peaks:'   num2str(sum(outOfRangePeakRRMask)) ...
    ' out of range RRs: ' num2str(sum(outOfRangeRRMask))];

ylabel(gca, 'RR Intervals')
yyaxis left
hold on
legend(legendObjs, legendString, ...
        'Location', 'southoutside', 'Orientation', 'Horizontal')
set(gcf, 'Name', baseTitle)
title({ekgPeaks.fileName; baseTitle}, 'Interpreter', 'None')
hold off
box on
