%% Run n-way analysis of variance on a triple of factors

peakFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\rrInfo.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Meta\meta.mat';
analysisDir = 'D:\TestData\NCTU_RWN_Heart_Analysis\anova';

%% Set the parameters
metaVariables = {'subject', 'task',  'group'};
rrMeasures = {'meanHR', 'meanRR', 'medianRR', ...
    'skewRR', 'kurtosisRR', 'iqrRR', ...
    'SDNN', 'SDSD', 'RMSSD', ...
    'NN50', 'pNN50', 'totalPower', ...
    'VLF', 'LF', 'LFnu', ...
    'HF', 'HFnu', 'LFHFRatio'};
rrMeasureTypes = {'overallValues', 'blockValues'};
rrScalingTypes = {'None', 'Subtract', 'Divide'};
scalingTask = 'Pre_EXP_resting';

%% Make sure that the plot directory exists
if ~isempty(analysisDir) && ~exist(analysisDir, 'dir')
    mkdir(analysisDir)
end

%% Load the info file
temp = load(infoFile);
params = temp.params;
rrInfo = temp.rrInfo;

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

subjects = {metadata.('subject')};
uniqueSubjects = unique(subjects);

%% Perform and consolidate the Anovas
aMap = containers.Map('KeyType', 'char', 'ValueType', 'any');

for k = 1:length(rrMeasureTypes)
    [rrValues, rrPositions] = ...
        consolidateRRMeasures(rrInfo, rrMeasureTypes{k}, rrMeasures);
    
    %% Create the index based on the scaling task
    tasks = {metadata.('task')};
    tasks = tasks(rrPositions);
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
        
        
        if ~isfield(metadata, metaVariables{1})
            error('%s is not a field of metadata', metaVariables{1});
            
        end
        thisMeta1 = {metadata.(metaVariables{1})};
        groups1 = thisMeta1(rrPositions);
        groups1 = groups1(taskMask);
        
        if ~isfield(metadata, metaVariables{2})
            error('%s is not a field of metadata.', metaVariables{2});
        end
        
        thisMeta2 = {metadata.(metaVariables{2})};
        groups2 = thisMeta2(rrPositions);
        groups2 = groups2(taskMask);
        
        thisMeta3 = {metadata.(metaVariables{3})};
        groups3 = thisMeta3(rrPositions);
        groups3 = groups3(taskMask);
        
        if ~isfield(metadata, metaVariables{3})
            error('%s is not a field of metadata.', metaVariables{3});
        end
        
        thisKey = [rrMeasureTypes{k} '_' rrScalingTypes{s} ...
            ':' metaVariables{1} '_' metaVariables{2} ...
            '_' metaVariables{3}];
        if isKey(aMap, thisKey)
            thisMap = aMap(thisKey);
            pValues = thisMap{1};
            fValues = thisMap{2};
            dfs = thisMap{3};
        else
            pValues =  NaN(6, length(rrMeasures));
            fValues = pValues;
            dfs = pValues;
        end
        
        for m = 1:length(rrMeasures)
            fprintf('%s %s %s %s %s %s\n', rrMeasures{m}, ...
                metaVariables{1}, metaVariables{2}, metaVariables{3},...
                rrScalingTypes{s}, rrMeasureTypes{k});
            theseValues = rrScaledValues(:, m);
            valueMask = ~isnan(theseValues) & ~isinf(theseValues);
            theseValues = theseValues(valueMask);
            theseGroups1 = groups1(valueMask);
            theseGroups2 = groups2(valueMask);
            theseGroups3 = groups3(valueMask);
            try
                [thePValues, theTable] =  anovan(theseValues(:), ...
                    {theseGroups1(:), theseGroups2(:), theseGroups3(:)}, ...
                    'model', 'interaction', 'display', 'off', ...
                    'varnames', {metaVariables{1}, metaVariables{2}, metaVariables{3}});
                pValues(:, m) = thePValues(:);
                fValues(:, m) = ...
                    [theTable{2, 6}; theTable{3, 6}; theTable{4, 6}; ...
                     theTable{5, 6}; theTable{6, 6}; theTable{7, 6}];
                dfs(:, m) = ...
                    [theTable{2, 3}; theTable{3, 3}; theTable{4, 3}; ...
                     theTable{5, 3}; theTable{6, 3}; theTable{7, 3}];
            catch Mex
                warning(Mex.identifier, 'Could not compute anova %s', Mex.message);
            end
        end
        
        aMap(thisKey) = {pValues, fValues, dfs};
    end
end


%% Now create as a structure
template = struct('type', NaN, 'measure', NaN, 'factor1', NaN, 'factor2', NaN, 'factor3', NaN);

for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_p']) = NaN;
    template.([rrScalingTypes{s} '_2_p']) = NaN;
    template.([rrScalingTypes{s} '_3_p']) = NaN;
    template.([rrScalingTypes{s} '_1x2_p']) = NaN;
    template.([rrScalingTypes{s} '_1x3_p']) = NaN;
    template.([rrScalingTypes{s} '_2x3_p']) = NaN;
end
for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_F']) = NaN;
    template.([rrScalingTypes{s} '_2_F']) = NaN;
    template.([rrScalingTypes{s} '_3_F']) = NaN;
    template.([rrScalingTypes{s} '_1x2_F']) = NaN;
    template.([rrScalingTypes{s} '_1x3_F']) = NaN;
    template.([rrScalingTypes{s} '_2x3_F']) = NaN;
end
for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_df']) = NaN;
    template.([rrScalingTypes{s} '_2_df']) = NaN;
    template.([rrScalingTypes{s} '_3_df']) = NaN;
    template.([rrScalingTypes{s} '_1x2_df']) = NaN;
    template.([rrScalingTypes{s} '_1x3_df']) = NaN;
    template.([rrScalingTypes{s} '_2x3_df']) = NaN;
end
anova3Info(1) = template;
totalVals = length(rrMeasureTypes)*length(rrMeasures);
anova3Info(totalVals) = template;
count = 0;
for k = 1:length(rrMeasureTypes)
    theseValues = {};
    for s = 1:length(rrScalingTypes)
        thisKey = [rrMeasureTypes{k} '_' rrScalingTypes{s} ...
            ':' metaVariables{1} '_' metaVariables{2} ...
            '_' metaVariables{3}];
        if ~isKey(aMap, thisKey)
            break;
        end
        theseValues{s} = aMap(thisKey); %#ok<*SAGROW>
    end
    if isempty(theseValues)
        break;
    end
    for m = 1:length(rrMeasures)
        
        count = count + 1;
        tStruct = template;
        tStruct.type = rrMeasureTypes{k};
        tStruct.measure = rrMeasures{m};
        
        tStruct.factor1 = metaVariables{1};
        tStruct.factor2 = metaVariables{2};
        tStruct.factor3 = metaVariables{3};
        for s = 1:length(rrScalingTypes)
            theValues = theseValues{s};
            pValues = theValues{1};
            fValues = theValues{2};
            dfValues = theValues{3};
            
            tStruct.([rrScalingTypes{s} '_1_p']) = pValues(1, m);
            tStruct.([rrScalingTypes{s} '_2_p']) = pValues(2, m);
            tStruct.([rrScalingTypes{s} '_1x2_p']) = pValues(3, m);
            tStruct.([rrScalingTypes{s} '_1_F']) = fValues(1, m);
            tStruct.([rrScalingTypes{s} '_2_F']) = fValues(2, m);
            tStruct.([rrScalingTypes{s} '_1x2_F']) = fValues(3, m);
            tStruct.([rrScalingTypes{s} '_1_df']) = dfValues(1, m);
            tStruct.([rrScalingTypes{s} '_2_df']) = dfValues(2, m);
            tStruct.([rrScalingTypes{s} '_1x2_df']) = dfValues(3, m);
        end
        anova3Info(count) = tStruct;
    end
end


%% Save the measures
save([analysisDir filesep 'anova3Measures.mat'], 'anova3Info', 'aMap', '-v7.3');
