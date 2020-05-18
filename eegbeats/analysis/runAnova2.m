%% Run n-way analysis of variance on pairs of factors


%% Set the file names
peakFile = 'D:\TestData\NCTU_RWN_VDE_IBIs\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_IBIs\rrInfo.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
analysisDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Analysis\anova';

%% Set the parameters
metaVariables = {'subject', 'group', 'task'};
rrMeasures = {'meanHR', 'meanRR', 'medianRR', 'SDNN', 'SDSD', 'RMSSD', ...
              'NN50', 'pNN50', 'totalPower', 'VLF', 'LF', 'LFnu', ...
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
     
        for g1 = 1:length(metaVariables)
            if ~isfield(metadata, metaVariables{g1})
                warning('%s is not a field of metadata...skipping', metaVariables{g1});
                continue;
            end
            thisMeta1 = {metadata.(metaVariables{g1})};
            groups1 = thisMeta1(rrPositions);
            groups1 = groups1(taskMask);
            for g2 = g1+1:length(metaVariables)
                if ~isfield(metadata, metaVariables{g1}) || g1 == g2
                    continue;
                end
                thisKey = [rrMeasureTypes{k} '_' rrScalingTypes{s} ...
                    ':' metaVariables{g1} '_', metaVariables{g2}];
                if isKey(aMap, thisKey)
                    thisMap = aMap(thisKey);
                    pValues = thisMap{1};
                    fValues = thisMap{2};
                    dfs = thisMap{3};
                else
                    pValues =  NaN(3, length(rrMeasures));
                    fValues = pValues;
                    dfs = pValues;
                end
                
                thisMeta2 = {metadata.(metaVariables{g2})};
                groups2 = thisMeta2(rrPositions);
                groups2 = groups2(taskMask);
                
                for m = 1:length(rrMeasures)
                    fprintf('%s %s %s %s %s\n', rrMeasures{m}, ...
                        metaVariables{g1}, metaVariables{g2}, ...
                        rrScalingTypes{s}, rrMeasureTypes{k});
                    theseValues = rrScaledValues(:, m);
                    valueMask = ~isnan(theseValues) & ~isinf(theseValues);
                    theseValues = theseValues(valueMask);
                    theseGroups1 = groups1(valueMask);
                    theseGroups2 = groups2(valueMask);
                    try
                        [thePValues, theTable] =  anovan(theseValues(:), ...
                            {theseGroups1(:), theseGroups2(:)}, ...
                            'model', 'interaction', 'display', 'off', ...
                            'varnames', {metaVariables{g1}, metaVariables{g2}});
                        pValues(:, m) = thePValues(:);
                        fValues(:, m) = ...
                            [theTable{2, 6}; theTable{3, 6}; theTable{4, 6}];
                        dfs(:, m) = ...
                            [theTable{2, 3}; theTable{3, 3}; theTable{4, 3}];
                    catch Mex
                        warning(Mex.identifier, 'Could not compute anova %s', Mex.message);
                    end
                end
                
                aMap(thisKey) = {pValues, fValues, dfs};
            end
        end
        
    end
end


%% Now create as a structure
template = struct('type', NaN, 'measure', NaN, 'factor1', NaN, 'factor2', NaN);

for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_p']) = NaN;
    template.([rrScalingTypes{s} '_2_p']) = NaN;
    template.([rrScalingTypes{s} '_1x2_p']) = NaN;
end
for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_F']) = NaN;
    template.([rrScalingTypes{s} '_2_F']) = NaN;
    template.([rrScalingTypes{s} '_1x2_F']) = NaN;
end
for s = 1:length(rrScalingTypes)
    template.([rrScalingTypes{s} '_1_df']) = NaN;
    template.([rrScalingTypes{s} '_2_df']) = NaN;
    template.([rrScalingTypes{s} '_1x2_df']) = NaN;
end
numCombos = length(metaVariables)*(length(metaVariables) - 1)/2;
anova2Info(1) = template;
totalVals = numCombos*length(rrMeasureTypes)*length(rrMeasures);
anova2Info(totalVals) = template;
count = 0;
for k = 1:length(rrMeasureTypes)
    for g1 = 1:length(metaVariables)
        for g2 = g1+1:length(metaVariables)
            theseValues = {};
            for s = 1:length(rrScalingTypes)
                thisKey = [rrMeasureTypes{k} '_' rrScalingTypes{s} ...
                    ':' metaVariables{g1} '_', metaVariables{g2}];
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
                   
                    tStruct.factor1 = metaVariables{g1};
                    tStruct.factor2 = metaVariables{g2};
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
                    anova2Info(count) = tStruct;     
            end
        end
    end
end

%% Save the measures
save([analysisDir filesep 'anova2Measures.mat'], 'anova2Info', 'aMap', '-v7.3');
