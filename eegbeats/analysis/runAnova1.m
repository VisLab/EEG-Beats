%% Display box plots of the distributions of the indicators by variable


%% Set the file names
peakFile = 'D:\TestData\NCTU_RWN_VDE_IBIs\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_IBIs\rrInfo.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
analysisDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Analysis\anova1';

%% Set the parameters
metaVariables = {'subject', 'group', 'task'};
rrMeasures = {'meanHR', 'meanRR', 'medianRR', 'SDNN', 'SDSD', 'RMSSD', ...
              'NN50', 'pNN50', 'totalPower', 'VLF', 'LF', 'LFnu', ...
              'HF', 'HFnu', 'LFHFRatio'};
rrMeasureTypes = {'overallValues', 'blockValues'};
rrScalingTypes = {'None', 'Subtract', 'Divide'};
scalingTask = 'Pre_EXP_resting';
%figFormats = {'.png', 'png'; '.fig', 'fig'; '.pdf' 'pdf'; '.eps', 'epsc'};
figFormats = {'.png', 'png'};
figClose = true;

%% Make sure that the plot directory exists
if ~isempty(analysisDir) && ~exist(analysisDir, 'dir')
    mkdir(analysisDir)
end

%% Load the info file
temp = load(infoFile);
params = temp.params;
rrInfo = temp.RRInfo;

%% Load the metadata file
temp = load(metaFile);
metadata = temp.meta;

%% Load the peak file
temp = load(peakFile);
ekgPeaks = temp.ekgPeaks;

%% Remove the bad RRInfo entries
infoMask = false(size(rrInfo));
for k = 1:length(rrInfo)
    if isempty(ekgPeaks(k).ekg) || sum(isnan(ekgPeaks(k).ekg)) > 0 || ...
       isempty(ekgPeaks(k).peakFrames) || sum(isnan(ekgPeaks(k).peakFrames)) > 0 || ...
       isnan(rrInfo(k).fileMinutes) 
       infoMask(k) = true;
       continue;
    end
end
rrInfo(infoMask) = [];

%% Create a map of metadata file names and position
metaMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:length(metadata)
    metaMap(metadata(k).fileName) = k;
end

%% Create an association between the rows of the metadata and rrInfo
metaIndex = zeros(size(rrInfo));
for k = 1:length(rrInfo)
    if isKey(metaMap, rrInfo(k).fileName)
        metaIndex(k) = metaMap(rrInfo(k).fileName);
    end
end
metadata(metaIndex==0) = [];
metaIndex(metaIndex==0) = [];
metadata = metadata(metaIndex);
rrInfo(metaIndex == 0) = [];

%% Plot the box plots
anova1Info = struct('metaVariables', NaN, 'rrMeasures', NaN, 'scaling', NaN, ...
                    'measureType', NaN, 'pValues', NaN, 'fValues', NaN, 'df', NaN);
anova1Info(length(rrMeasureTypes)*length(rrScalingTypes)) = anova1Info(1);
count = 0;
for k = 1:length(rrMeasureTypes)
    [rrValues, rrPositions] = ...
        consolidateRRMeasures(rrInfo, rrMeasureTypes{k}, rrMeasures);
    %% Create the index based on the scaling task
    theseTasks = {metadata.('task')};
    tasks = theseTasks(rrPositions);
    tasks = tasks(:);
    scalingTaskMask = strcmpi(tasks, scalingTask);
    scalingPosIndex = (1:length(scalingTaskMask))';
    curInd = 1;
    for n = 2:length(scalingPosIndex)
        if scalingTaskMask(n)
            curInd = n;
        else
            scalingPosIndex(n) = curInd;
        end
    end
    for s = 1:length(rrScalingTypes)
        %% Perform scaling if required
        if strcmpi(rrScalingTypes{s}, 'None')
            rrScaledValues = rrValues;
            taskMask = true(size(scalingTaskMask));
            scalingString = 'No scaling';
            scalingLine = NaN;
        elseif strcmpi(rrScalingTypes{s}, 'Subtract')
            baseValues = rrValues(scalingPosIndex, :);
            rrScaledValues = rrValues - baseValues;
            taskMask = ~scalingTaskMask;
            rrScaledValues = rrScaledValues(taskMask, :);
            scalingString = ['Scaled by subtracting ' scalingTask];
            scalingLine = 0;
        elseif strcmpi(rrScalingTypes{s}, 'Divide')
            baseValues = rrValues(scalingPosIndex, :);
            rrScaledValues = rrValues./baseValues;
            taskMask = ~scalingTaskMask;
            rrScaledValues = rrScaledValues(taskMask, :);
            scalingString = ['Scaled by dividing ' scalingTask];
            scalingLine = 1;
        end
        
        pValues = nan(length(rrMeasures), length(metaVariables));
        fValues = nan(length(rrMeasures), length(metaVariables));
        df = nan(length(rrMeasures), length(metaVariables));
        for g = 1:length(metaVariables)
            if ~isfield(metadata, metaVariables{g})
                warning('%s is not a field of metadata...skipping', metaVariables{g});
                continue;
            end
            thisMeta = {metadata.(metaVariables{g})};
            groups = thisMeta(rrPositions);
            groups = groups(taskMask);
            
         
            for m = 1:length(rrMeasures)
                theseValues = rrScaledValues(:, m);
                valueMask = ~isnan(theseValues) & ~isinf(theseValues);
                theseValues = theseValues(valueMask);
                theseGroups = groups(valueMask);
                [pValues(m, g), theTable] = anova1(theseValues(:), theseGroups(:), 'off');  
                fValues(m, g) = theTable{2, 5};
                df(m, g) = theTable{2, 3};
                if isnan(pValues(m, g))
                    pause;
                end
            end
      
        end
        count = count + 1;
        anova1Info(count) = anova1Info(end);
        anova1Info(count).metaVariables = metaVariables;
        anova1Info(count).rrMeasures = rrMeasures;
        anova1Info(count).scaling = rrScalingTypes{s};
        anova1Info(count).measureType = rrMeasureTypes{k};
        anova1Info(count).pValues = pValues;
        anova1Info(count).fValues = fValues;
        anova1Info(count).df = df;     
    end
end

%% Save the measures
save([analysisDir filesep 'anova1Measures.mat'], 'anova1Info', '-v7.3');