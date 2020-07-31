function [ekgPeaks, rrInfo, rrMeasures] = getEmptyBeatStructs()
%% Return empty structures for peaks, RR information and RR measures
%
%  Note: This function is used for efficiency to preallocate structures
%% Get the structures
ekgPeaks = struct('fileName', NaN, 'srate', NaN, 'ekg', NaN, ...
    'peakFrames', NaN, 'lowAmplitudePeaks', NaN, 'highAmplitudePeaks', NaN);
              
rrInfo = struct('fileName', NaN, 'fileMinutes', NaN, 'overallValues', NaN, ...
                 'blockMinutes', NaN, 'blockStepMinutes', NaN, 'blockValues', NaN);

rrMeasures = struct('startMinutes', NaN, ...
                  'totalRRs', 0, 'numRRs', 0, ...
                  'numRemovedOutOfRangeRRs', 0, ...
                  'numRemovedBadNeighbors', 0, ...
                  'numRemovedAroundOutlierAmpPeaks', 0, ...
                  'meanHR', NaN, 'meanRR', NaN, 'medianRR', NaN, ...
                  'skewRR', NaN, 'kurtosisRR', NaN, 'iqrRR', NaN, ...
                  'trendSlope', NaN, 'SDNN', NaN, 'SDSD', NaN, ...
                  'RMSSD', NaN, 'NN50', NaN, 'pNN50', NaN, ...
                  'spectrumType', NaN, 'totalPower', NaN, ...
                   'VLF', NaN, 'LF', NaN,   'LFnu', NaN, ...
                   'HF', NaN, 'HFnu', NaN, 'LFHFRatio', NaN, ...
                   'PSD', NaN, 'F', NaN);        
                   