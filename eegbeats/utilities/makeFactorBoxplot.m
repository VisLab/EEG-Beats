function hFig = makeFactorBoxplot(values, groups, measureName, metaName, baseTitle, scalingLine)

   
    mprt = prctile(values, [25, 50, 75]);
    hFig = figure('Name', baseTitle{1});
    hold on
    bxs = boxplot(values, groups);
    xLim = get(gca, 'XLim');
    line([xLim(1), xLim(2)], [mprt(2), mprt(2)], 'LineStyle', '-', 'Color', [0.7, 0.7, 0.7])
    line([xLim(1), xLim(2)], [mprt(1), mprt(1)], 'LineStyle', '--', 'Color', [0.7, 0.7, 0.7])
    line([xLim(1), xLim(2)], [mprt(3), mprt(3)], 'LineStyle', '--', 'Color', [0.7, 0.7, 0.7])
    if ~isnan(scalingLine)
        line([xLim(1), xLim(2)], [scalingLine, scalingLine], 'LineStyle', '--', 'Color', [0.2, 0.2, 0.7])
    end
    hold off
    [~, cols] = size(bxs);
    for j1 = 1:cols
        set(bxs(5, j1), 'Color', [0, 0, 0], 'LineWidth', 1);
        set(bxs(6, j1), 'Color', [1, 0, 0], 'LineWidth', 1);
    end
    title(baseTitle, 'Interpreter', 'None')
    xlabel(metaName)
    ylabel(measureName)