function hFig = makePeakPlot(ekgPeaks, baseTitle, params)   
%% Creates a figure of the ekg overlaid with the peaks that it found

%%  Create a figure
    hFig = figure('Name', baseTitle, 'Visible', params.figureVisibility);

    title({ekgPeaks.fileName; baseTitle}, 'Interpreter', 'None')
    xlabel('Seconds')
    ylabel('EKG signal')
    box on
    
%% See if there is ekg to plot    
    ekg = ekgPeaks.ekg;
    peakFrames = ekgPeaks.peakFrames;
   if isempty(ekg) || (isscalar(ekg) && isnan(ekg)) 
       warning('%s: does not have any ekg', params.fileName);
       return;
   end
    
    %% We have ekg, so plot it
    seconds = (0:(length(ekg) - 1))./params.srate;
    plot(seconds, ekg);
    
    %% See if there are peaks to plot 
    if isempty(peakFrames) || (isscalar(peakFrames) && isnan(peakFrames))
       warning('%s: does not have any heart beats', params.fileName);
       return;
    end
    lowPeaks = ekgPeaks.lowAmplitudePeaks;
    peakPrts = prctile(ekg(peakFrames), [25, 50, 75]);
    hold on;
    plot(seconds(peakFrames), ekg(peakFrames), 'r*', 'MarkerSize', 10);
    if ~isempty(lowPeaks) || ~isscalar(lowPeaks) || ...
       (isscalar(lowPeaks) && ~isnan(lowPeaks))
        plot(seconds(lowPeaks), ekg(lowPeaks), 'xk', ...
            'MarkerSize', 12, 'LineWidth', 2)
    end
    line([0, max(seconds)], [peakPrts(1), peakPrts(1)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    line([0, max(seconds)], [peakPrts(2), peakPrts(2)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0, 0.8, 0]);
    line([0, max(seconds)], [peakPrts(3), peakPrts(3)], 'LineWidth', 1, 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7]);
    set(hFig, 'position', [0 0 2000 500])

    hold off

