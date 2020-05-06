%% Display box plots of the distributions of the indicators by variable


%% Set the file names
peakFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_14\ekgPeaks.mat';
infoFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_14\rrInfo.mat';
metaFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
plotDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Analysis_14';

%% Set the parameters
metaVariables = {'subject', 'group'};
rrMeasures = {'meanHR', 'meanRR'};
rrMeasureTypes = {'overallValues'};

%% Make sure that the plot directory exists
if ~isempty(plotDir) && ~exist(plotDir, 'dir')
    mkdir(plotDir)
end

%% Load the info file
temp = load(infoFile);
params = temp.params;
RRInfo = temp.RRInfo;

%% Load the metadata file
temp = load(metaFile);
metadata = temp.meta;

%% Load the peak file
temp = load(peakFile);
ekgPeaks = temp.ekgPeaks;

RRInfo(20).fileMinutes = NaN;
RRInfo(285).fileMinutes = NaN;
RRInfo(443).fileMinutes = NaN;

%% Mask out the files that don't have RRInfo
badInfoMask = isnan(cell2mat({RRInfo.fileMinutes}));
RRInfo(badInfoMask) = [];

%% Create associations between the RRInfo entries and the metadata entries
infoMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:length(RRInfo)
    infoMap(RRInfo(k).fileName) = k;
end
fileIndex = NaN(size(RRInfo));
metaMask = false(size(metadata));
for k = 1:length(metadata)
    if ~isKey(infoMap, metadata(k).fileName)
        warning('%s at meta position %d does not ibi info')
        metaMask(k) = true;
        continue;
    end
    fileIndex(k) = infoMap(metadata(k).fileName);
end

% Remove from rrInfo items that don't correspond to meta data
fprintf('%d items in rrInfo do not have metadata and are being removed\n', sum(isnan(fileIndex)));
RRInfo(isnan(fileIndex)) = [];
fileIndex(isnan(fileIndex)) = [];
fprintf('%d items in metadata do not have rrInfo and are being removed\n', sum(metaMask));
metadata(metaMask) = [];

% Now remap the ibiInfo to correspond to the metadata
RRInfo = RRInfo(fileIndex);

rrMeasureType = 'blockValues';
ibiMeasure = 'meanRR';

[values, positions] = consolidateIBIMeasures(RRInfo, rrMeasureType, ibiMeasure);


%% Now
for m = 1%1:length(metaVariables)
    if ~isfield(metadata, metaVariables{m})
        warning('%s is not a field of metadata...skipping', metaVariables{m});
        continue;
    end
    groups = {metadata.(metaVariables{m})};
    groups = groups(positions);
    baseTitle = ['Distribution (' rrMeasureType ') by ' metaVariables{m} ' of ' ibiMeasure];
    hFig = makeFactorBoxplot(values, groups, ibiMeasure, metaVariables{m}, baseTitle);
 
end

%% Now perform plot the box plots