% dlg_blinker - GUI for entering BLINKER parameters temporary example test
%

% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, 51 Franklin Street, Boston, MA 02110-1301, USA

function [outStruct, okay] = dlg_eegbeats(params)
okay = true;
theTitle = 'eegbeats parameters';
closeOpenWindows(theTitle);
fileDirCb = ['saveFile = get(findobj(''parent'', gcbf, ''tag'', ''fileDir''), ''String'');' ...
              '[fileName, pathName] = uiputfile(''*.mat'', ''beats output'', saveFile); drawnow;' ...
              'if fileName(1) ~= 0,' ...
              '   set(findobj(''parent'', gcbf, ''tag'', ''fileDir''), ''string'', [ pathName fileName ]);' ...
              'end;' ...
             ];
figureDirCb = ['dumpDir = get(findobj(''parent'', gcbf, ''tag'', ''figureDir''), ''String'');' ...
             'dumpDirName = uigetdir(dumpDir, ''beats figure directory''); drawnow;' ...
             'if dumpDirName(1) ~= 0,' ...
             '   set(findobj(''parent'', gcbf, ''tag'', ''figureDir''), ''string'', dumpDirName);' ...
             'end;' ...
             ];
ekgCb = ['ekgDir = get(findobj(''parent'', gcbf, ''tag'', ''ekgChannelLabel''), ''String'');' ...
             'ekgDirName = uigetdir(ekgDir, ''ekgChannelLabel''); drawnow;' ...
             'if ekgDirName(1) ~= 0,' ...
             '   set(findobj(''parent'', gcbf, ''tag'', ''ekgChannelLabel''), ''string'', ekgDirName);' ...
             'end;' ...
             ];
 signalTypeMenu = {'True'; 'False'};
 signalTypeValue =  find(strcmpi(signalTypeMenu, params.removeOutOfRangeRRs.value), 1, 'first');


%% Set up the geometry for the GUI
% geometry = {[3, 5, 2], [3, 5, 2], [3, 5, 2], [3, 5, 2], [3, 5, 2], ...
%             [3, 5, 2], [3, 5, 2], [3, 5, 2], [3, 5, 2], [3, 5, 2], ...
%             [3, 5, 2], [3, 2, 3, 2],  [3, 2, 3, 2]}; 
geometry = {[1, 5, 2],[1, 5, 2],[1, 5, 2],[3],[3, 5, 3, 5],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2], ...
            [3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2],[3, 5, 3, 5, 2], ...
            [3, 5, 3, 5, 2],[3, 5, 3, 5, 2]};%,[3, 1, 3, 1]};
uilist = { ...
    { 'Style', 'text', 'string', 'fileDir', ...
    'horizontalalignment', 'right', ...
    'TooltipString', params.fileDir .description}, ... 
    { 'Style', 'edit', 'string', params.fileDir.value, ...
    'horizontalalignment', 'left', 'tag',  'fileDir ', ...
    'TooltipString', params.fileDir.description}, ...
    { 'Style', 'pushbutton', 'string', 'Browse...', 'callback', fileDirCb},... %Row 1
    { 'Style', 'text', 'string', 'figureDir', ...
    'horizontalalignment', 'right', ...
    'TooltipString', params.figureDir.description}, ... 
    { 'Style', 'edit', 'string', params.figureDir.value, ...
    'horizontalalignment', 'left', 'tag',  'figureDir', ...
    'TooltipString', params.figureDir.description}, ...
    { 'Style', 'pushbutton', 'string', 'Browse...', 'callback', figureDirCb},... %Row 2
    { 'Style', 'text', 'string', 'ekgChannelLabel', ...
    'horizontalalignment', 'right', ...
    'TooltipString', params.ekgChannelLabel.description}, ... 
    { 'Style', 'edit', 'string', params.ekgChannelLabel.value, ...
    'horizontalalignment', 'left', 'tag',  'ekgChannelLabel', ...
    'TooltipString', params.ekgChannelLabel.description}, ...
    { 'Style', 'pushbutton', 'string', 'Browse...', 'callback', ekgCb},... %Row 3
    { 'Style', 'text', 'string', '', ...
      'horizontalalignment', 'right'}, ...                                 % empty line
    { 'Style', 'text', 'string', 'Find Peaks Setting', ...
      'horizontalalignment', 'right'}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...
    { 'Style', 'text', 'string', 'RR Measure Setting', ...
      'horizontalalignment', 'right'}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % titles
    { 'Style', 'text', 'string', 'filterHz', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.filterHz.description}, ...
    { 'Style', 'edit', 'string', params.filterHz.value, ...
      'horizontalalignment', 'left',  'tag',  'filterHz', ...
      'TooltipString', params.filterHz.description}, ...
    { 'Style', 'text', 'string', 'rrsAroundOutlierAmpPeaks', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrsAroundOutlierAmpPeaks.description}, ...
    { 'Style', 'edit', 'string', params.rrsAroundOutlierAmpPeaks.value, ...
      'horizontalalignment', 'left',  'tag',  'rrsAroundOutlierAmpPeaks', ...
      'TooltipString', params.rrsAroundOutlierAmpPeaks.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % filterHz and rrsAroundOutlierAmpPeaks
    { 'Style', 'text', 'string', 'srate', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.srate.description}, ...
    { 'Style', 'edit', 'string', params.srate.value, ...
      'horizontalalignment', 'left',  'tag',  'srate', ...
      'TooltipString', params.srate.description}, ...
    { 'Style', 'text', 'string', 'rrOutlierNeighborhood', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrOutlierNeighborhood.description}, ...
    { 'Style', 'edit', 'string', params.rrOutlierNeighborhood.value, ...
      'horizontalalignment', 'left',  'tag',  'rrOutlierNeighborhood', ...
      'TooltipString', params.rrOutlierNeighborhood.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % srate and rrOutlierNeighborhood
    { 'Style', 'text', 'string', 'truncateThreshold', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.truncateThreshold.description}, ...
    { 'Style', 'edit', 'string', params.truncateThreshold.value, ...
      'horizontalalignment', 'left',  'tag',  'truncateThreshold', ...
      'TooltipString', params.truncateThreshold.description}, ...
    { 'Style', 'text', 'string', 'rrPercentToBeOutlier', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrPercentToBeOutlier.description}, ...
    { 'Style', 'edit', 'string', params.rrPercentToBeOutlier.value, ...
      'horizontalalignment', 'left',  'tag',  'rrPercentToBeOutlier', ...
      'TooltipString', params.rrPercentToBeOutlier.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % truncateThreshold and rrPercentToBeOutlier
    { 'Style', 'text', 'string', 'rrMaxMs', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrMaxMs.description}, ...
    { 'Style', 'edit', 'string', params.rrMaxMs.value, ...
      'horizontalalignment', 'left',  'tag',  'rrMaxMs', ...
      'TooltipString', params.rrMaxMs.description}, ...
    { 'Style', 'text', 'string', 'rrBlockMinutes', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrBlockMinutes.description}, ...
    { 'Style', 'edit', 'string', params.rrBlockMinutes.value, ...
      'horizontalalignment', 'left',  'tag',  'rrBlockMinutes', ...
      'TooltipString', params.rrBlockMinutes.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % rrMaxMs and rrBlockMinutes
    { 'Style', 'text', 'string', 'rrMinMs', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrMinMs.description}, ...
    { 'Style', 'edit', 'string', params.rrMinMs.value, ...
      'horizontalalignment', 'left',  'tag',  'rrMinMs', ...
      'TooltipString', params.rrMinMs.description}, ...
    { 'Style', 'text', 'string', 'rrBlockStepMinutes', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.rrBlockStepMinutes.description}, ...
    { 'Style', 'edit', 'string', params.rrBlockStepMinutes.value, ...
      'horizontalalignment', 'left',  'tag',  'rrBlockStepMinutes', ...
      'TooltipString', params.rrBlockStepMinutes.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'},...  % rrMinMs and rrBlockStepMinutes
    { 'Style', 'text', 'string', 'threshold', ... 
      'horizontalalignment', 'right', ...
      'TooltipString',params.threshold.description}, ...
    { 'Style', 'edit', 'string', params.threshold.value, ...
      'horizontalalignment', 'left',  'tag',  'threshold', ...
      'TooltipString', params.threshold.description}, ...
    { 'Style', 'text', 'string', 'detrendOrder', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.detrendOrder.description}, ...
    { 'Style', 'edit', 'string', params.detrendOrder.value, ...
      'horizontalalignment', 'left',  'tag',  'detrendOrder', ...
      'TooltipString', params.detrendOrder.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % threshold and detrendOrder
    { 'Style', 'text', 'string', 'qrsDurationMs', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.qrsDurationMs.description}, ...
    { 'Style', 'edit', 'string', params.qrsDurationMs.value, ...
      'horizontalalignment', 'left',  'tag',  'qrsDurationMs', ...
      'TooltipString', params.qrsDurationMs.description}, ...
    { 'Style', 'text', 'string', 'removeOutOfRangeRRs', ...
      'horizontalalignment', 'right', ...
      'TooltipString', params.removeOutOfRangeRRs.description}, ... 
    { 'Style', 'popupmenu', 'string', 'True|False', ...
      'value', signalTypeValue, 'horizontalalignment', 'left',  ...
      'tag', 'removeOutOfRangeRRs', ...
       'TooltipString', params.removeOutOfRangeRRs.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...6  % qrsDurationMs and removeOutOfRangeRRs
    { 'Style', 'text', 'string', 'flipIntervalSeconds', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.flipIntervalSeconds.description}, ...
    { 'Style', 'edit', 'string', params.flipIntervalSeconds.value, ...
      'horizontalalignment', 'left',  'tag',  'flipIntervalSeconds', ...
      'TooltipString', params.flipIntervalSeconds.description}, ...
    { 'Style', 'text', 'string', 'spectrumType', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.spectrumType.description}, ...
    { 'Style', 'edit', 'string', params.spectrumType.value, ...
      'horizontalalignment', 'left',  'tag',  'spectrumType', ...
      'TooltipString', params.spectrumType.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % flipIntervalSeconds and spectrumType
    { 'Style', 'text', 'string', 'flipDirection', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.flipDirection.description}, ...
    { 'Style', 'edit', 'string', params.flipDirection.value, ...
      'horizontalalignment', 'left',  'tag',  'flipDirection', ...
      'TooltipString', params.flipDirection.description}, ...
    { 'Style', 'text', 'string', 'arMaxModelOrder', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.arMaxModelOrder.description}, ...
    { 'Style', 'edit', 'string', params.arMaxModelOrder.value, ...
      'horizontalalignment', 'left',  'tag',  'arMaxModelOrder', ...
      'TooltipString', params.arMaxModelOrder.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % flipDirection** and arMaxModelOrder
    { 'Style', 'text', 'string', 'consensusIntervals', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.consensusIntervals.description}, ...
    { 'Style', 'edit', 'string', params.consensusIntervals.value, ...
      'horizontalalignment', 'left',  'tag',  'consensusIntervals', ...
      'TooltipString', params.consensusIntervals.description}, ...
    { 'Style', 'text', 'string', 'resampleHz', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.resampleHz.description}, ...
    { 'Style', 'edit', 'string', params.resampleHz.value, ...
      'horizontalalignment', 'left',  'tag',  'resampleHz', ...
      'TooltipString', params.resampleHz.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % consensusIntervals and resampleHz
    { 'Style', 'text', 'string', 'maxPeakAmpRatio', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.maxPeakAmpRatio.description}, ...
    { 'Style', 'edit', 'string', params.maxPeakAmpRatio.value, ...
      'horizontalalignment', 'left',  'tag',  'maxPeakAmpRatio', ...
      'TooltipString', params.maxPeakAmpRatio.description}, ...
    { 'Style', 'text', 'string', 'freqCutoff', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.freqCutoff.description}, ...
    { 'Style', 'edit', 'string', params.freqCutoff.value, ...
      'horizontalalignment', 'left',  'tag',  'freqCutoff', ...
      'TooltipString', params.freqCutoff.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'},...  % maxPeakAmpRatio and freqCutoff
    { 'Style', 'text', 'string', 'minPeakAmpRatio', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.minPeakAmpRatio.description}, ...
    { 'Style', 'edit', 'string', params.minPeakAmpRatio.value, ...
      'horizontalalignment', 'left',  'tag',  'minPeakAmpRatio', ...
      'TooltipString', params.minPeakAmpRatio.description}, ...
    { 'Style', 'text', 'string', 'VLFRange', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.VLFRange.description}, ...
    { 'Style', 'edit', 'string', params.VLFRange.value, ...
      'horizontalalignment', 'left',  'tag',  'VLFRange', ...
      'TooltipString', params.VLFRange.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}, ...  % minPeakAmpRatio and VLFRange:
    { 'Style', 'text', 'string', 'maxWhisker', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.maxWhisker.description}, ...
    { 'Style', 'edit', 'string', params.maxWhisker.value, ...
      'horizontalalignment', 'left',  'tag',  'maxWhisker', ...
      'TooltipString', params.maxWhisker.description}, ...
    { 'Style', 'text', 'string', 'LFRange', ...
      'horizontalalignment', 'right', ...
      'TooltipString',params.LFRange.description}, ...
    { 'Style', 'edit', 'string', params.LFRange.value, ...
      'horizontalalignment', 'left',  'tag',  'LFRange', ...
      'TooltipString', params.LFRange.description}, ...
    { 'Style', 'text', 'string', '', 'horizontalalignment', 'right'}};% minPeakAmpRatio and LFRange
%     {'style', 'text', 'string', 'doPlot', ...
%         'TooltipString', params.doPlot.description}, ...
%     {'style', 'checkbox',  'Value', params.doPlot.value, ...
%         'tag', 'doPlot'}, ...
%     {'style', 'text', 'string', 'figureVisibility', ...
%         'TooltipString', params.figureVisibility.description}, ...
%     {'style', 'checkbox',  'Value', params.figureVisibility.value, ...
%         'tag', 'figureVisibility'}, ...
%     {'style', 'text', 'string', 'figureClose', ...
%         'TooltipString', params.figureClose.description}, ...
%     {'style', 'checkbox',  'Value', params.figureClose.value, ...
%         'tag', 'figureClose'}};% Row 13 



%% Call the GUI
[~, ~, ~, outStruct] = inputgui(geometry, uilist);
if isempty(outStruct) % Cancel was hit
    okay = false;
    return;
end
%% Massage the GUI return values to fit BLINKER's expectations
outStruct.signalTypeIndicator = signalTypeMenu{outStruct.signalTypeIndicator};
outStruct.dumpBlinkerStructures = logical(outStruct.doPlot);
outStruct.showMaxDistribution = logical(outStruct.showMaxDistribution);
outStruct.dumpBlinkPositions = logical(outStruct.dumpBlinkPositions);
outStruct.dumpBlinkImages = logical(outStruct.dumpBlinkImages);
if ~isempty(outStruct.signalNumbers)
    outStruct.signalNumbers = sort(str2num(outStruct.signalNumbers)); %#ok<ST2NM>
else
    outStruct.signalNumbers = NaN;
end
if ~isempty(outStruct.signalLabels)
    outStruct.signalLabels = str2cellstr(outStruct.signalLabels);
end
    function closeOpenWindows(windowName)
        openWindow = findobj('Type', 'Figure', '-and', 'Name', windowName);
        if ~(isempty(openWindow))
            close(openWindow);
        end
    end
    
    function outString = cellstr2str(signalLabels)
         outString = '';
         if isempty(signalLabels) || ~iscellstr(signalLabels) 
             return;
         end
         outString = signalLabels{1};
         for n = 2:length(signalLabels)
             outString = [outString ',' signalLabels{n}]; %#ok<AGROW>
         end
    end
    
    function outCell = str2cellstr(labelValues)
         pieces = strsplit(labelValues, ',');
         outCell = cell(1, length(pieces));
         if isempty(pieces)
             return;
         end
         for n = 1:length(pieces)
             outCell{n} = pieces{n};
         end
         outCell = sort(outCell);
    end

end