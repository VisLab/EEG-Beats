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
%rrMeasureTypes = {'overallValues', 'blockValues'};
rrMeasureTypes = {'blockValues'};
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
        scaledPositions = rrPositions(taskMask);
        
        metaLabels = cell(length(rrScaledValues), length(metaVariables));
        for g = 1:length(metaVariables)
            if ~isfield(metadata, metaVariables{g})
                error('%s is not a field of metadata...', metaVariables{g});
            end
            thisMeta = {metadata.(metaVariables{g})};
            metaLabels(:, g) = thisMeta(scaledPositions);
        end
        
        %% Now scale the data before doing tsne
        rrScaledValues1 = bsxfun(@minus, rrScaledValues, mean(rrScaledValues));
        rrScaledValues1 = bsxfun(@rdivide, rrScaledValues1, std(rrScaledValues));
        siteShapes = {'<', 'o', '>', 's', 'd', '*', 'x'};
        %% 
        for g = 1:length(metaVariables)
            uniqueMeta = unique(metaLabels(:, g));
            for m = 1:length(uniqueMeta)
                metaMask = strcmpi(metaLabels(:, g), uniqueMeta{m});
                theseValues = rrScaledValues1(metaMask, :);
                theseLabels = metaLabels(metaMask, :);
                theseLabels(:, g) = [];
                tsneValues = tsne(theseValues);
                
                baseTitle = [metaVariables{g} ' ' uniqueMeta{m}];
                figure('Name', baseTitle)
                gscatter(tsneValues(:, 1), tsneValues(:, 2), theseLabels(:, 2));
                title(baseTitle);
                
                legendString = {};
theLimits = [-60, 60];
hFigSite = figure('Name', ['By site: ' theTitle]);
hold on
for n = 1:numStudies
    if uniqueStudies(n) == 0
        continue;
    end
    for m = 1:numSites
        thisMask = legendSites(:, 1) == m & legendSites(:, 2) == n;
        if sum(thisMask) == 0
            continue;
        end
        
        plot(tsneResults(thisMask, 1), tsneResults(thisMask, 2), ...
            'Color', studyColors(n, :), 'LineStyle', 'none', 'LineWidth', 0.5, ...
            'MarkerSize', 10, 'Marker', siteShapes{m});
        legendString{end + 1} = [sites{m} '-' studies{uniqueStudies(n), shortPos}]; %#ok<AGROW>
    end
end
            end
        end
    end
end

