%% This script processes a file, runs it, and plots it.
loadPath = 'E:\sabrina\documents\EEGLab\Brenda_EegData\New';
savePath = 'E:\sabrina\documents\EKG\ProcessedFromBrendasEEG';
%filename = 'eeg_NCTU_RWN_VDE_session_3_subject_1_task_PVT_recording_1.set';
%filename = 'eeg_NCTU_RWN_VDE_session_159_subject_1_task_PVT_recording_1.set';
filename = 'eeg_NCTU_RWN_VDE_session_160_subject_1_task_LKT_recording_1.set';
%filename = 'eeg_NCTU_RWN_VDE_session_161_subject_1_task_DAS_High_recording_1.set';

%% Process
convertEegToEkg([loadPath filesep filename], savePath, 128);

%% Get Beats
eeg = pop_loadset([savePath filesep filename]);
%eeg.data = eeg.data(200*eeg.srate:300*eeg.srate);
[ brPeaks, brPeaksTm ] = getHeartBeats(eeg);

%% Plot
plotDifferences(eeg, brPeaks, filename);

% Get IBI
ibi = generateIBI(brPeaksTm, 1.5);

x = 0;