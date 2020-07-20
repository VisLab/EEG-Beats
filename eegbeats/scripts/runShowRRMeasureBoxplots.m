%% Display boxplots of RR measures segregated by metadata variable

%% Set the file names
peakFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2\rrInfoWithRemoval30SecStep.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Meta\meta.mat';
plotDir = 'D:\TestData\NCTU_RWN_Heart_Analysis_Data2\boxplots';

%% Set the parameters
%metaVariables = {'subject', 'group', 'task'};
metaVariables = {'subject'};
% rrMeasures = {'meanHR', 'meanRR', 'medianRR', 'SDNN', 'SDSD', 'RMSSD', ...
%               'NN50', 'pNN50', 'totalPower', 'VLF', 'LF', 'LFnu', 'LFHFRatio'};
rrMeasures = {'LFnu'};
%rrMeasureTypes = {'overallValues', 'blockValues'};
rrMeasureTypes = {'blockValues'};
rrScalingTypes = {'None', 'Subtract', 'Divide'};
scalingTask = 'Pre_EXP_resting';
figFormats = {'.png', 'png'; '.fig', 'fig'; '.pdf' 'pdf'; '.eps', 'epsc'};
%figFormats = {'.png', 'png'};
%figClose = true;
figClose = false;
%% Make sure that the plot directory exists
if ~isempty(plotDir) && ~exist(plotDir, 'dir')
    mkdir(plotDir)
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

%% Plot the box plots
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
                valueMask = ~isnan(theseValues);
                theseValues = theseValues(valueMask);
                theseGroups = groups(valueMask);
                fprintf('%s: %s has %d nans\n', metaVariables{g}, rrMeasures{m}, sum(~valueMask));
                
                %% Now plot the box plot
                baseTitle = {[rrMeasures{m} ' ' rrMeasureTypes{k} ' grouped by '  ...
                      metaVariables{g}]; scalingString};
                hFig = makeFactorBoxplot(theseValues, theseGroups, ...
                                rrMeasures{m}, metaVariables{g}, baseTitle, scalingLine);
                saveName = [rrMeasures{m} '_groupedBy_' metaVariables{g} '_' ...
                    rrMeasureTypes{k} '_Scaling_' rrScalingTypes{s}];
                saveFigures(hFig, [plotDir filesep saveName], figFormats, figClose);
            end
        end
    end
end

