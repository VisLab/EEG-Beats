% Show plots of the indicators in different groups for the shooter data
% This script produced Figure 4 of the paper

%
% BLINKER extracts blinks and ocular indices from time series. 
% Copyright (C) 2016  Kay A. Robbins, Kelly Kleifgas, UTSA
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

%% Declare files and file paths
ibiDir = ('I:/Brenda/Documents/MATLAB/Variables/MATLABScripts/Results/');
summaryFile = ('ibiStructure');
aNovaFile = 'aNovanIBIwithTasks';
pValuesForIndicators = 'sigFigArray'; %located in aNovanIBIwithTasks
%% Load the summary file
load([ibiDir filesep summaryFile]);

%% Declare variables to be used in script
subjects = {ibiStatsSummary.subjectID};
fatigueLevels = {ibiStatsSummary.fatigueLevel};
uniqueSubjects = unique(subjects);
saveFlag = false;

%% Specify indicator types
indicatorType = {'mean', 'sdnn', 'rmssd', 'nn50', 'pnn50', 'rrt', 'ppSD1', ...
    'ppSD2', 'ppRatio'};
% numAnovaVariations = 6;
% pValues = cell(length(indicatorType), numAnovaVariations);  % 6 variations of anova

for k = 1:length(indicatorType)
    fprintf('Indicator %d: %s\n', k, indicatorType{k});
    subjectInd = ['subject' indicatorType{k}];
    
    %% Create new array for box plot reference
    indicatorBase = {ibiStatsSummary.(indicatorType{k})};
    theseIndicators = nan(length(indicatorBase),1);
    for n = 1:length(theseIndicators)
        theseIndicators(n) = indicatorBase{n}(1);
    end
    %% Compute subject subtraction and division scaling
    indicatorsSub = theseIndicators;
    indicatorsDiv = theseIndicators;
   
    for s = 1:length(uniqueSubjects)
        thisSubject = uniqueSubjects{s};
        fatigueMask = strcmpi(fatigueLevels, 'none');
        thisIndex = strcmpi(subjects, thisSubject);
        thisAverage = mean(theseIndicators(thisIndex & fatigueMask));
        indicatorsSub(thisIndex) = indicatorsSub(thisIndex) - thisAverage;
        indicatorsDiv(thisIndex) = indicatorsDiv(thisIndex)./thisAverage;
    end
    
    %% Plot groups using boxplots
    figure('Name', [indicatorType{k} ': grouped']);
    boxplot(theseIndicators, fatigueLevels, 'notch', 'on', ...
        'labels', {'high', 'low', 'normal'}, 'colors', [0, 0, 0])
    ylabel(indicatorType{k})
    box on
    set(gca, 'YGrid', 'on');
%     ax = gca;
%     ax.YGrid = 'on';
    set(gca, 'LineWidth', 1)
    title([indicatorType{k} ': grouped']);
    
    %% Plot groups using boxplots DIV
    figure('Name', [indicatorType{k} ': grouped/DIV']);
    boxplot(indicatorsDiv, fatigueLevels, 'notch', 'on', ...
        'labels', {'low', 'high', 'normal'}, 'colors', [0, 0, 0], ...
        'datalim', [0, 2.5])
    ylabel(indicatorType{k})
    box on
    set(gca, 'YGrid', 'on');
%         ax = gca;
%     ax.YGrid = 'on';
    set(gca, 'LineWidth', 1)
    %set(gca, 'GridLineStyle', ':', 'XGrid', 'on', 'YGrid', 'off');
    title([indicatorType{k} ': grouped/DIV']);
    
    %% Plot groups using boxplots SUB
    figure('Name', [indicatorType{k} ': grouped/SUB']);
    boxplot(indicatorsSub, fatigueLevels, 'notch', 'on', ...
        'labels', {'low', 'high', 'normal'}, 'colors', [0, 0, 0])
    ylabel(indicatorType{k})
    box on
    set(gca, 'YGrid', 'on');
%     ax = gca;
%     ax.YGrid = 'on';
    set(gca, 'LineWidth', 1)
    title([indicatorType{k} ': grouped/SUB']);
    
   %% Plot subjects using boxplots
    figure('Name', [indicatorType{k}]);
    boxplot(theseIndicators, subjects, 'labels', ...
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', ...
        'N', 'O', 'P', 'Q'}, 'colors', [0, 0, 0])
    ylabel(indicatorType{k})
    xlabel('Subjects')
    box on
    set(gca, 'LineWidth', 1) % 'YLim', [0, 30]
    set(gca, 'YGrid', 'on');
%     ax = gca;
%     ax.YGrid = 'on';
    title([indicatorType{k}]);
    
    %% Plot subjects using boxplots DIV
    figure('Name', [indicatorType{k} ': Div']);
    boxplot(indicatorsDiv, subjects, 'labels', ...
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', ...
        'N', 'O', 'P', 'Q'}, 'colors', [0, 0, 0])
    ylabel([indicatorType{k} ': scaled'])
    xlabel('Subjects')
    box on
    set(gca, 'YGrid', 'on');
%     ax = gca;
%     ax.YGrid = 'on';
    set(gca, 'LineWidth', 1, 'YLim', [0, 3])
    title([indicatorType{k} ': Subject Div']);
    
    
    %% Plot subjects using boxplots SUB
    figure('Name', [indicatorType{k} ': Sub']);
    boxplot(indicatorsSub, subjects, 'labels', ...
        {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', ...
        'N', 'O', 'P', 'Q'},'colors', [0, 0, 0])
    ylabel(indicatorType{k})
    xlabel('Subjects')
    box on
    set(gca, 'YGrid', 'on');
%     ax = gca;
%     ax.YGrid = 'on';
    set(gca, 'LineWidth', 1)
    title([indicatorType{k} ': Subject Sub']);
    %%
    numSubjects = length(uniqueSubjects);
    myColors = jet(numSubjects);
    for n = 1:numSubjects
        
    end
    
    outDir = ('I:/Brenda/Documents/MATLAB/Variables/MATLABScripts/Results/BoxPlots');
    if saveFlag
       % See if you can save multiple plots for each iteration 
    end
    
end