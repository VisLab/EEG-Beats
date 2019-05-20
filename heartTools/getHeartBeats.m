 function [ peaksIdx, peaksTm ] = getHeartBeats( EEG, minDist, maxDist )
%GETHEARTBEATS Find heartbeats within a signal.
%   Gets the heartbeats within a given ekg signal. More of a wrapper around
%   getBeatRefinement
%   Parameters:
%       EEG     The EEG struct from EEGLab.
%       minDist minimum distance between peaks in seconds
%       maxDist maximum distance between peaks in seconds
%       peaksIdx
%               the peak indicies the algorithm finds
%       peaksTm
%               the peak times the algorithm finds
%   Example:
%           [peaksIdx, peaksTm] = getHeartBeats(EEG)
%%

%Create a time vector in samples
t = 1:length(EEG.data);
t = (t-1)/EEG.srate;

% Shorted time for an IBI values is .6 seconds and longest is 1.5 seconds
qrsDuration = 0.1;
consensusIntervalLen = 5;

%Find R peaks using the Beat Refinment and Pan-Tompkins algorithms
[peaksIdx, peaksTm] = getBeatRefinement(EEG.data, t, EEG.srate, minDist,...
    maxDist, qrsDuration, consensusIntervalLen);
end

