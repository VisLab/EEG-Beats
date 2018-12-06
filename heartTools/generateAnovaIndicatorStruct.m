%% Get the indicators for each EEG struct

%% Get metadata and set up paths
metadataPath = 'E:\sabrina\Documents\EKG\Anova\NCTU_RWN_VDE_metadata';
sessionsBase = 'Z:\Data 3\NCTU_RWN_VDE_128Hz\session';
savePath = 'E:\sabrina\Documents\EKG\Anova\IndicatorStruct.mat';
saveBadDataPath = 'E:\sabrina\Documents\EKG\Anova\BadDataList.mat';
minSrate = 128;
test = load(metadataPath);
metadata = test.metadata;
ibiMaxDist = 1.5;
ibiMinDist = 0.1;
numDataSets = length(metadata);
badData = [];

%% Set up the struct
ibiStatsSummary(numDataSets) = struct('session', NaN, 'level1Name', NaN, ...
    'subjectID', NaN, 'task', NaN, 'fatigue', NaN, 'mean', NaN, ...
    'sdnn', NaN, 'rmssd', NaN, 'nn50', NaN, 'pnn50', NaN, 'rrt', NaN);

% Populate the basic data
for i = 1:numDataSets
    % NaN it out
    ibiStatsSummary(i) = ibiStatsSummary(end);
    
    % Set some of the values
    ibiStatsSummary(i).level1Name = metadata(i).level1Name;
    ibiStatsSummary(i).subjectID = metadata(i).subjectID;
    ibiStatsSummary(i).session = metadata(i).session;
    ibiStatsSummary(i).task = metadata(i).task;
    ibiStatsSummary(i).fatigue = metadata(i).fatigue;
end

%% Get the indicators
validMask = true(numDataSets, 1);
for i = 1:numDataSets
    %i = 114;
    if i < 234%0%61%230%226%61%13% 23
        continue;
    end
    %if ismember(i, badElements)
        %validMask(i) = false;
        %continue;
    %end
    
    % load the data
    dataPath = [sessionsBase filesep int2str(ibiStatsSummary(i).session) ...
        filesep '*.set'];
    files = dir(dataPath);
    
    if isempty(files)
        badData = [badData i];
        validMask(i) = false;
        continue;
    end

    % process the data
    eeg = pop_loadset([files(1).folder filesep files(1).name]);
    eeg = getEkgFromEeg(eeg, minSrate);    
     
    if isempty(eeg) 
        validMask(i) = false;
        continue;
    end
    
    figure;
    title(i);
    hold on;
    plot(eeg.data);
    % Get the indicators
    try
        [peaks, peaksTm] = getHeartBeats(eeg);
        
        %if length(peaks) < eeg.times(end)/10000
            %error('Invalid data: Too few peaks');
        %end
        
        % Generate the ibi
        %plot(peaks, eeg.data(peaks), 'r*');
    	ibi = generateIBI(peaksTm(1,:), ibiMaxDist, ibiMinDist);
        indicators = getIBIIndicators(ibi(:,2));        
    catch EX
        % Print a warning message and add to badData list
        warning('Invalid data. Skipping');
        badData = [badData i];
        validMask(i) = false;
        continue;
    end
    %figure;
    %hold on;
    %plot(eeg.data);
    plot(peaks(1,:), eeg.data(peaks(2,:)), 'r*');
    %close all;
    % Get the indicators
    % set the indicators
    ibiStatsSummary(i).mean = indicators(1);
    ibiStatsSummary(i).sdnn = indicators(2);
    ibiStatsSummary(i).rmssd = indicators(3);
    ibiStatsSummary(i).nn50 = indicators(4);
    ibiStatsSummary(i).pnn50 = indicators(5);
    ibiStatsSummary(i).rrt = indicators(6);
end

%% Save
ibiStatsSummary = ibiStatsSummary(validMask);
save(savePath, 'ibiStatsSummary');
save(saveBadDataPath, 'badData');