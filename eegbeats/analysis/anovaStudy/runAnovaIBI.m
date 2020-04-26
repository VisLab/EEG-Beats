
%% Load everything you need
structDir = ('I:\Brenda\Documents\MATLAB\variables\MATLABScripts\Results');
structToLoad = 'ibiStructure';

load([structDir filesep structToLoad]);

%% Create subjects
subject = {ibiStatsSummary.subjectID};
hand = {ibiStatsSummary.hand};
fatigueLevel = {ibiStatsSummary.fatigueLevel};


%% Initialize base structures

baseStruct = struct('ibiIndex', NaN, 'aNovaType', NaN, ...
                    'p', NaN, 'pTable', NaN, 'pStats', NaN);
indicatorType = {'mean', 'sdnn', 'rmssd', 'nn50', 'pnn50', 'rrt'};
numAnovaVariations = 4;
pValues = cell(length(indicatorType),numAnovaVariations); 

for k = 1:length(indicatorType)
    fprintf('Indicator %d: %s\n', k, indicatorType{k});
    subjectInd = ['subject ' indicatorType{k}];
    fatigueInd = ['fatigue ' indicatorType{k}];
    handInd = ['hand ' indicatorType{k}];
    theseIndicators = nan(length(ibiStatsSummary), 1);
    for n = 1:length(theseIndicators)
        theseIndicators(n) = ibiStatsSummary(n).(indicatorType{k});
    end
    
    %% Calculate aNova for subjects versus fatigue
    
    [p, theTable, theStats] = anovan(theseIndicators, {subject, fatigueLevel},...
        'display', 'off', 'varnames', {subjectInd, 'fatigue'});
    b = baseStruct;
    b.ibiIndex = indicatorType{k};
    b.aNovaType = 'Subject-Fatigue';
    b.p = p;
    b.pTable = theTable;
    b.pStats = theStats;
    pValues{k,1} = b;
    
    %% Calculate aNova for subject versus hand
    
    [p, theTable, theStats] = anovan(theseIndicators, {subject, hand},...
        'display', 'off', 'varnames', {subjectInd, 'hand'});
    b = baseStruct;
    b.ibiIndex = indicatorType{k};
    b.aNovaType = 'Subject-Hand';
    b.p = p;
    b.pTable = theTable;
    b.pStats = theStats;
    pValues{k,2} = b;
    
    %% Calculate aNova for fatigue versus hand
    
    [p, theTable, theStats] = anovan(theseIndicators, {fatigueLevel, hand},...
        'display', 'off', 'varnames', {fatigueInd, 'hand'});
    b = baseStruct;
    b.ibiIndex = indicatorType{k};
    b.aNovaType = 'Fatigue-Hand';
    b.p = p;
    b.pTable = theTable;
    b.pStats = theStats;
    pValues{k,3} = b;
    
    %% Calculate aNova for subjects-fatigue-hand
    
    [p, theTable, theStats] = anovan(theseIndicators, ...
        {subject, fatigueLevel, hand}, 'display', 'off', 'varnames', ...
        {subjectInd, 'fatigue', 'hand'});
    b = baseStruct;
    b.ibiIndex = indicatorType{k};
    b.aNovaType = 'Subject-fatigue-Hand';
    b.p = p;
    b.pTable = theTable;
    b.pStats = theStats;
    pValues{k,4} = b;
    
end

%% Save the file

%% Print out indicators

