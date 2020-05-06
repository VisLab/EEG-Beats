function hFig = makeFactorBoxplot(values, groups, measureName, metaName, baseTitle)

   
    mprt = prctile(values, [25, 50, 75]);
    hFig = figure('Name', baseTitle)
    hold on
    bxs = boxplot(values, groups);
    xLim = get(gca, 'XLim');
    line([xLim(1), xLim(2)], [mprt(2), mprt(2)], 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7])
    line([xLim(1), xLim(2)], [mprt(1), mprt(1)], 'LineStyle', '--', 'Color', [0.7, 0.7, 0.7])
    line([xLim(1), xLim(2)], [mprt(3), mprt(3)], 'LineStyle', '--', 'Color', [0.7, 0.7, 0.7])
    hold off
    [~, cols] = size(bxs);
    for j1 = 1:cols
        set(bxs(5, j1), 'Color', [0, 0, 0], 'LineWidth', 1);
        set(bxs(6, j1), 'Color', [1, 0, 0], 'LineWidth', 1);
    end
    title(baseTitle)
    xlabel(metaName)
    ylabel(measureName)