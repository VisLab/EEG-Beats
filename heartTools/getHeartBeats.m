 function [ brPeaksIdx, brPeaksTm ] = getHeartBeats( EEG )
%GETHEARTBEATS Find heartbeats within a signal.
%   Find heart beats within a single channel and compare the result with the
%   Pan-Tompkins QRS Detection algorithm.
%
%   Parameters:
%       EEG     The EEG struct from EEGLab.
%       brPeaks
%               the peaks Brenda's algorithm finds with respect to time
%       brPeaksTm
%               the peaks Pan-Tompkins finds with respect to the index
%
%   Example:
%           [ibi, brMatched, brUnmatched, ptUnmatched] = getHeartBeats(EEG)
%%

%Create a time vector in samples
t = 1:length(EEG.data);
t = (t-1)/EEG.srate;
%figure
%plot(t, EEG.data);

% Shorted time for an IBI values is .6 seconds and longest is 1.5 seconds
below = 0.5;
above = 1.5;
qrsDuration = 0.1;
consensusIntervalLen = 1;

%Find R peaks using the Beat Refinment and Pan-Tompkins algorithms
[brPeaksIdx, brPeaksTm] = getBeatRefinement(EEG.data, t, EEG.srate, below,...
    above, qrsDuration, consensusIntervalLen);
%[~,ptPeaksIdx,~] = getPanTompkinsPeaks(double(EEG.data),EEG.srate,0);

%Compare algorithms and find IBI values
%[ ibi, brMatched, brUnmatched, ptUnmatched ] = findConsecutiveRR( brPeaksIdx, ptPeaksIdx );


end

