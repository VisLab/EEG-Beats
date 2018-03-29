function [ ibi, brMatched, brUnmatched, ptUnmatched ] = getHeartBeats( EEG )
%GETHEARTBEATS Find heartbeats within a signal.
%   Find heart beats within a single and compare the result with the
%   Pan-Tompkins QRS Detection algorithm.
%
%   Parameters:
%       EEG     The EEG struct from EEGLab.
%       ibi     (output) A two column array containing the time the R peak
%               occured and the beat inervals in seconds. 
%       brMatched
%               (output) The heart beats detected using the Beat Refinement
%               algorithm that were matched with the Pan-Tompkin algorithm.
%       brUnmatched
%               (output) The heart beats detected using the Beat Refinement
%               algorithm that were not matched with the Pan-Tompkins
%               algorithm. 
%       ptUnmatched
%               (output) The heart beats detected using the Pan-Tompkins
%               algorithm that were not matched with the Beat Refinement
%               algorithm. 
%
%   Example:
%           [ibi, brMatched, brUnmatched, ptUnmatched] = getHeartBeats(EEG)
%%

% Shorted time for an IBI values is .6 seconds and longest is 1.5 seconds
below = 0.6;
above = 1.5;

% If the sampling frequency is not 200, resample. 
if ~(EEG.srate == 200)
    EEG = pop_resample( EEG, 200);
end

% Filter the data
EEG = pop_eegfiltnew(EEG, 1, 20, 660,0,[],0);

% Remove other channels and keep only the EKG data
EEG.data = EEG.data(63,:);
EEG.nbchan = 1;
EEG.chanlocs = EEG.chanlocs(63);

%Create a time vector in samples
t = 1:length(EEG.data);

%Find R peaks using the Beat Refinment and Pan-Tompkins algorithms
brPeaks = getBeatRefinement(EEG.data, t, EEG.srate, below, above);
[~,ptPeaks,~] = getPanTompkinsPeaks(double(EEG.data),EEG.srate,0);

%Compare algorithms and find IBI values
[ ibi, brMatched, brUnmatched, ptUnmatched ] = findConsecutiveRR( brPeaks, ptPeaks );


end

