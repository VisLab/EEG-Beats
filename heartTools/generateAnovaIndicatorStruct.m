%% Get the indicators for each EEG struct
% The following script performs several different tasks
% 1.   Get the ekg signal for each eeg file at the given filter
% 2.   Get the peaks and troughs for each signal
% 3.   Get the IBI indicators for each signal
% 4.   (optional) will plot each signal with the peaks and troughs marked

%% Get metadata and set up paths
metadataPath = 'E:\sabrina\Documents\EKG\Anova\NCTU_RWN_VDE_metadata';
sessionsBase = 'Z:\Data 3\NCTU_RWN_VDE_128Hz\session';
savePathFolder = 'E:\sabrina\Documents\EKG\Anova\';

minSrate = 128;
test = load(metadataPath);
metadata = test.metadata;
ibiMaxDist = 1.5;
ibiMinDist = 0.1;
numDataSets = length(metadata);
eeg_filter_low = 3;
eeg_filter_high = 20;
badData = [];
low = int2str(eeg_filter_low);
high = int2str(eeg_filter_high);

% save paths for all the structs
savePathIbI = [savePathFolder filesep 'IndicatorStruct' ...
    '_low=' low '_high=' high '.mat'];
savePathError = [savePathFolder filesep 'IndicatorErrorStruct' ...
    '_low=' low '_high=' high '.mat'];
savePathEkg = [savePathFolder filesep 'EkgData' ...
    '_low=' low '_high=' high '.mat'];
savePathPeaks = [savePathFolder filesep 'EkgPeaks' ...
    '_low=' low '_high=' high '.mat'];
saveBadDataPath = [savePathFolder filesep 'BadDataList' ...
    '_low=' low '_high=' high '.mat'];
doPlot = 0;
figPath = 'E:\sabrina\Documents\eegHeartPlots\images\fig';
pngPath = 'E:\sabrina\Documents\eegHeartPlots\images\png';

%% Set up the struct
% Create a new directory for all of the stats summary info
% Run and upload to visual data.

% ekg signal
    % session, filename
    % srate, ekg signal array
ekgSignal(numDataSets) = struct('session', NaN, 'filename', NaN, ...
    'srate', NaN, 'signal', NaN);

% peaks 
    % session, filename, srate
    % start times of the peaks
    % the corresponding troughs
ekgPeaks(numDataSets) = struct('session', NaN, 'filename', NaN, ...
    'srate', NaN, 'peakTime', NaN, 'troughTime', NaN);

ibiStatsSummary(numDataSets) = struct('session', NaN, 'level1Name', NaN, ...
    'subjectID', NaN, 'task', NaN, 'fatigue', NaN, 'mean', NaN, ...
    'sdnn', NaN, 'rmssd', NaN, 'nn50', NaN, 'pnn50', NaN, 'rrt', NaN);

ibiErrorSummary(numDataSets) = struct('session', NaN, 'filename', NaN, ...
    'tooLarge', NaN, 'tooSmall', NaN, 'errorMsg', NaN);

% Populate the basic data
for i = 1:numDataSets
    % NaN it out
    ekgSignal(i) = ekgSignal(end);
    ekgPeaks(i) = ekgPeaks(end);
    ibiStatsSummary(i) = ibiStatsSummary(end);
    ibiErrorSummary(i) = ibiErrorSummary(end);
    
    % Set some of the values
    ibiStatsSummary(i).level1Name = metadata(i).level1Name;
    ibiStatsSummary(i).subjectID = metadata(i).subjectID;
    ibiStatsSummary(i).session = metadata(i).session;
    ibiStatsSummary(i).task = metadata(i).task;
    ibiStatsSummary(i).fatigue = metadata(i).fatigue;
    ibiErrorSummary(i).session = metadata(i).session;
    ekgSignal(i).session = metadata(i).session;
    ekgPeaks(i).session = metadata(i).session;
end

%% Get the indicators
validMask = true(numDataSets, 1);
for i = 1:numDataSets
    % load the data
    dataPath = [sessionsBase filesep int2str(ibiStatsSummary(i).session) ...
        filesep '*.set'];
    files = dir(dataPath);
    
    if isempty(files)
        badData = [badData i];
        validMask(i) = false;
        continue;
    end

    % set the filename
    ibiErrorSummary(i).filename = files(1).name; 
    ekgSignal(i).filename = files(1).name; 
    ekgPeaks(i).filename = files(1).name; 
    
    % process the data
    eeg = pop_loadset([files(1).folder filesep files(1).name]);
    eeg = getEkgFromEeg(eeg, minSrate, eeg_filter_low, eeg_filter_high);  
    
    % set the srate and the signal
    ekgSignal(i).srate = minSrate; 
    ekgSignal(i).signal = eeg;
    ekgPeaks(i).srate = minSrate; 
    
    if isempty(eeg) 
        validMask(i) = false;
        continue;
    end

    % Get the indicators
    try
        [peaks, peaksTm] = getHeartBeats(eeg);
        ekgPeaks(i).peakTm = peaksTm(1,:);
        ekgPeaks(i).troughTm = peaksTm(2,:);
        
        % Generate the ibi
    	[ibi, ibiErrorSummary(i).tooLarge, ibiErrorSummary(i).tooSmall] = ...
            generateIBI(peaksTm(1,:), ibiMaxDist, ibiMinDist);
        indicators = getIBIIndicators(ibi(:,2));        
    catch EX
        ibiErrorSummary(i).errorMsg = EX.message;
        for e=1:length(EX.stack)
            mystr = sprintf(' in %s at %i\n', ...
                EX.stack(e).name, EX.stack(e).line);
            ibiErrorSummary(i).errorMsg = ...
                strcat(ibiErrorSummary(i).errorMsg, mystr);
        end
        % Print a warning message and add to badData list
        warning('Invalid data. Skipping');
        badData = [badData i];
        validMask(i) = false;
        continue;
    end
    
    % Plot the data if we want to
    if doPlot
        figure;
        hold on;
        plot(eeg.data);

        plot(peaks(1,:), eeg.data(peaks(1,:)), 'r*');
        plot(peaks(2,:), eeg.data(peaks(2,:)), 'g*');
        set(h, 'position', [0 0 3000 1500])
        saveas(h, [figPath filesep 'images_' int2str(i) '.fig'], 'fig');
        saveas(h, [pngPath filesep 'images_' int2str(i) '.png'], 'png');
        close all;
    end
    
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

save(savePathIbI, 'ibiStatsSummary');
save(savePathError, 'ibiErrorSummary');
save(savePathPeaks, 'ekgPeaks');
save(savePathEkg, 'ekgSignal');
save(saveBadDataPath, 'badData');