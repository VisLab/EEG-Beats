function hFig = makePeakPlot(ekg, peakFrames, plotTitle, params)   
%% Creates a figure of the ekg overlaid with the peaks that it found
   
    peakPrts = prctile(ekg(peakFrames), [25, 50, 75]);

    seconds = (0:(length(ekg) - 1))./params.srate;
    hFig = figure('Name', plotTitle{1}, 'Visible', params.figureVisibility);
    hold on;
    plot(seconds, ekg);
    plot(seconds(peakFrames), ekg(peakFrames), 'r*', 'MarkerSize', 10);
    line([0, max(seconds)], [peakPrts(1), peakPrts(1)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    line([0, max(seconds)], [peakPrts(2), peakPrts(2)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0, 0.8, 0]);
    line([0, max(seconds)], [peakPrts(3), peakPrts(3)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    set(hFig, 'position', [0 0 2000 500])

    hold off

    title(plotTitle, 'Interpreter', 'None')
    xlabel('Seconds')
    ylabel('EKG signal')
    box on