%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script creates a structure that includes variables of      %
% raw IBI values. The group structure is then saved for analysis. %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Initialize variables to be used in script
    
% The folder for the Eeg data


    %leftDir and rightDir are structs, we only want names of the files.
leftDir = dir(fullfile(leftFolder, '*.mat'));
rightDir = dir(fullfile(rightFolder, '*.mat'));
    % Extract the names of the files
leftNames = extractfield(leftDir, 'name');
rightNames = extractfield(rightDir, 'name');
    % Concatenate in a single column array for faster iteration
allFileNames = [leftNames(:); rightNames(:)];

structLength = length(leftDir) + length(rightDir);
saveFlag = true;

%% Define group structure
ibiStatsSummary(structLength) = struct('fileName', NaN, 'subjectID', NaN, ...
    'fatigueCode', NaN, 'fatigueLevel', NaN, 'hand', NaN, 'mean', NaN, ...
    'sdnn', NaN, 'rmssd', NaN, 'nn50', NaN, 'pnn50', NaN, 'rrt', NaN);


%% Fill in groupStruct
for i=1:structLength
    [~, name, ~] = fileparts(char(allFileNames(i))); %[pathstr, name, ext]
    ibiStatsSummary(i).fileName = name;
    ibiFileToken = strsplit(char(name), '_');
    ibiStatsSummary(i).subjectID = ibiFileToken{1};
    ibiStatsSummary(i).fatigueCode = ibiFileToken{2};
        % Use the fatigueCode for fatigueLevel
        tmp = ibiStatsSummary(i).fatigueCode;
            if iscell(tmp)
                tmp = cell2mat(tmp);
            end
        if tmp(1) == 'H'
            ibiStatsSummary(i).fatigueLevel = 'high';
        end
        if tmp(1) == 'L'
            ibiStatsSummary(i).fatigueLevel = 'low';
        end
        if tmp(1) == 'N'
            ibiStatsSummary(i).fatigueLevel = 'none';
        end    
    ibiStatsSummary(i).hand = ibiFileToken{3};
    
        % Decide which folder to use to load data
    if ( strcmp(name(end-1:end),'LH'))
         file = fullfile(leftFolder, name);
         load(file, 'IBI_rawdata');
         rrIntervals = IBI_rawdata(2:end,2);
         values = getTimeDomainIndicators(rrIntervals);
    end
    if ( strcmp(name(end-1:end),'RH'))
         file = fullfile(rightFolder, name);
         load(file, 'IBI_rawdata');
         rrIntervals = IBI_rawdata(2:end,2);
         values = getTimeDomainIndicators(rrIntervals);
    end
        % Values is an array that contains [meanRR, SDNN, RMSSD, NN50,
        % pNN50, and RRT]
    ibiStatsSummary(i).mean = values(1,1);
    ibiStatsSummary(i).sdnn = values(1,2);
    ibiStatsSummary(i).rmssd = values(1,3);
    ibiStatsSummary(i).nn50 = values(1,4);
    ibiStatsSummary(i).pnn50 = values(1,5);
    ibiStatsSummary(i).rrt = values(1,6);
    %groupStruct(i).tinn = values(1,7);, TINN hasnt been coded yet
    fclose all;
end
if saveFlag
    output = ('I:/Brenda/Documents/MATLAB/Variables/MATLABScripts/Results/ibiStructure');
    save(output, 'ibiStatsSummary');
end

