%% Step through the images and to view

%% Set the paths
imageDir = 'D:\TestData\NCTU_RWN_VDE_IBI_Images6';

%% Get a list of files
figFiles = getFileAndFolderList(imageDir, {'*.fig'}, true);
numFiles = length(figFiles);

%% Create session map
sessionMap = containers.Map('KeyType', 'char', 'ValueType', 'any');
for k = 1:numFiles
    [thePath, theName] = fileparts(figFiles{k});
    pieces = strsplit(theName, '_');
    sessionMap(pieces{2}) = k;
end
%% Get the indicators
for n = 1:numFiles
    nKey = num2str(n);
    if ~isKey(sessionMap, nKey)
        warning('Session %s does not have file', nKey);
        continue;
    end
    k = sessionMap(nKey);
    h = open(figFiles{k});
    pause;
   
end