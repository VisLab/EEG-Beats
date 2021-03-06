%% Create a correctly-formated metadata structure from existing metadata.
%
% EEG-Beats requires a metadata structure in a specified format in order to
% do analysis of variance and its boxplots and TSNE visualizations. The
% first field of the metadata structure should be the fileName. This
% fileName should be exactly the same file name as the one appearing in
% both the ekgPeaks structure and the rrInfo structure. EEG-Beats uses the
% fileName as a key to match metadata to RR measures. 
%
% All other fields in the structure will be treated as fixed effect
% categorical data. EEG-Beats uses the field name as the factor name.
%
%% Set up directory and load the files
metadataFile = ['D:\TestData\Level1WithBlinks\NCTU_RWN_VDE\additional_documentation' ...
               filesep 'NCTU_RWN_VDE_metadata.mat'];   
saveFile = 'D:\TestData\NCTU_RWN_VDE_Heart\meta.mat';
temp = load(metadataFile);
metadata = temp.metadata;

%% We had different naming for the files so we will need to create a map
rawDir = 'D:\TestData\Level1WithBlinks\NCTU_RWN_VDE';
EEGFiles = getFileAndFolderList(rawDir, {'*.set'}, true);
numFiles = length(EEGFiles);
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    [thePath, theName, ~] = fileparts(EEGFiles{k});
    pieces = strsplit(thePath, filesep);
    sessionMap(pieces{end}) = theName;
end

%% Create the new structure
numFiles = length(metadata);
meta = struct('fileName', NaN, 'subject', NaN, ...
              'group', NaN, 'gender', NaN, 'task', NaN, ...
              'replicate', NaN, 'date', NaN);
meta(numFiles) = meta(1);
for k = 1:numFiles
    meta(k) = meta(end);
    [~, theName, theExt] = fileparts(metadata(k).level1Name);
    session = num2str(metadata(k).session);
    if ~isKey(sessionMap, session)
        warning('Session %s does not have an entry in the session key', session);
        continue;
    end
    fileName = sessionMap(session);
    meta(k).fileName = ['session_' num2str(metadata(k).session) '_' fileName];
    meta(k).subject = metadata(k).subjectInfo.labId;
    meta(k).group = metadata(k).fatigue;
    meta(k).gender = metadata(k).subjectInfo.gender;
    meta(k).task = metadata(k).task;
    meta(k).replicate = metadata(k).replicate;
    meta(k).date = metadata(k).ESSDateTime;
end

%% Now save the file
save(saveFile, 'meta', '-v7.3');