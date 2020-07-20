%% Convert peak positions to two-column text files with position and IBI.

%% Set up the file names
ekgFile = 'D:\TestData\NCTU_RWN_VDE_IBIs_12\ekgPeaks.mat';
outputDir=  'D:\TestData\NCTU_RWN_VDE_IBIs_TXT_12';

%% Load the files the heartbeat file
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
numFiles = length(ekgPeaks);

%% Make sure that the output directory is created
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% Now do the files
for k = 1%:numFiles
    fileName = ekgPeaks(k).fileName;
    pos = strfind(fileName, 'eeg');
    filePrefix = fileName(1:pos - 1);
    fd = fopen([outputDir filesep filePrefix 'ekg.txt'], 'w');
    ekg = ekgPeaks(k).ekg;
    fprintf(fd, '%g\n', ekg);
    fclose(fd);
    fd = fopen([outputDir filesep filePrefix 'ibis.txt'], 'w');
    peaks = ekgPeaks(k).peakFrames;
    peakTimes = (peaks - 1)./ekgPeaks(k).srate;
    ibis = peakTimes(2:end) - peakTimes(1:end-1);
    fprintf(fd, '%g\n', ibis);
    fclose(fd);
end