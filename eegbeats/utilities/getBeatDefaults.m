function defaults = getBeatDefaults()
% Returns the default settings for EEG-Beats
%
% Parameters:
% Output:
%     defaults     a structure with the parameters for the default types
%                  in the form of a structure that has fields
%                     value: default value
%                     classes:   classes that the parameter belongs to
%                     attributes:  attributes of the parameter
%                     description: description of parameter
%
% EEG-Beats extracts heart beats and associated RR measures.
% Copyright (C) 2020  UTSA
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

    defaults = struct( ...
        'ekgChannelLabel', ...
         getRules('ekg', {'char'}, {}, ...
        'Label of the EEG channel containing the EKG signal.'), ...
        'filterHz', ...
        getRules([3, 20], {'numeric'}, {'positive', 'row', 'size', [1, 2]}, ...
        'Frequency band to filter raw signal before detecting heartbeats.'), ...
        'srate', ...
        getRules(128, {'numeric'}, {'scalar', 'positive'}, ...
        'Frequency to resample raw ekg signal at before filtering'), ...
        'truncateThreshold', ...
        getRules(15, {'numeric'}, {'positive', 'scalar'}, ...
        'Number of robust stds away from median to truncate ekg before detecting heartbeats.'), ...
        'rrMaxMs', ...
        getRules(1500, {'numeric'}, {'positive', 'scalar'}, ...
        'Maximum number of milliseconds between peaks for valid RRs.'), ...
        'rrMinMs', ...
        getRules(500, {'numeric'}, {'positive', 'scalar'}, ...
        'Minimum number of milliseconds between peaks for valid RRs.'), ...
        'threshold', ...
        getRules(1.5, {'numeric'}, {'positive', 'scalar'}, ...
        'Minimum heartbeat amplitude in units of robust stds away from median signal.'), ...
        'qrsDurationMs', ...
        getRules(200, {'numeric'}, {'positive', 'scalar'}, ...
        'Maximum width of a heartbeat peak in milliseconds.'), ...
        'flipIntervalSeconds', ...
        getRules(2, {'numeric'}, {'positive', 'scalar'}, ...
        'Length of subintervals in partition of signal to determine dominant heartbeat direction.'), ...
        'consensusIntervals', ...
        getRules(31, {'numeric'}, {'positive', 'scalar', 'integer'}, ...
        'Number of intervals to partition the signal to determine initial fenceposts.'), ...
        'doPlot', ...
        getRules(true, {'logical'}, {}, ...
        'If true, produce a plot of EKG signal with heartbeats marked.'), ...
        'figureVisibility', ...
        getRules('on', {'char'}, {}, ...
        'If true, shows figures, otherwise creates but does not display (for non-interactive mode).'), ...
        'figureClose', ...
        getRules(false, {'logical'}, {}, ...
        'If true, closes the figure after displaying/saving it.'), ...
        'fileDir', ...
        getRules('', {'char'}, {}, ...
        'If non-empty, base name(including path) of the file for saving.'), ...
        'figureDir', ...
         getRules('', {'char'}, {}, ...
        'If not empty, base name (including path) to to save the plot as a .fig and a .png file.'), ...
        'verbose', ...
        getRules(true, {'logical'}, {}, ...
        'If true, output intermediate algorithm information.'), ...
        'doRRMeasures', ...
         getRules(true, {'logical'}, {}, ...
        'If true, calculate RR measures.'), ...
        'rrBlockMinutes', ...
         getRules(5, {'numeric'}, {'positive', 'scalar'}, ...
        'Block size in minutes for computing RR measures.'), ...
        'rrBlockStepMinutes', ...
         getRules(2.5, {'numeric'}, {'positive', 'scalar'}, ...
        'Minutes to slide window for computing RR measures.'), ...
        'detrendOrder', ...
         getRules(3, {'numeric'}, {'nonnegative', 'scalar'}, ...
        'Order of polynomial for detrending RRs or 0 if no detrend prior to computing the measures.'), ...
        'removeOutOfRangeRRs', ...
         getRules(true, {'logical'}, {}, ...
        'If true remove RRs that are too small or too large prior to computing the measures.'), ...
         'spectrumType', ...
         getRules('lomb', {'char'}, {}, ...
        'Type of spectrum: ''lomb'', ''ar'', ''fft''.'), ...
         'arMaxModelOrder', ...
         getRules(25, {'numeric'}, {'integer', 'positive'}, ...
        'Maximum order of the AR model fit to determine AR spectrum.'), ...
        'resampleHz', ...
         getRules(4, {'numeric'}, {'positive'}, ...
        'Resampling frequency for FFT representation of spectrum'), ...
        'freqCutoff', ...
         getRules(0.4, {'numeric'}, {'positive', 'scalar'}, ...
        'Upper frequency bound in Hz for computing total power in IBI spectrum.'), ...
         'VLFRange', ...
         getRules([0.005, 0.04], {'numeric'}, {'positive', 'row', 'size', [1, 2]}, ...
        'Upper frequency bound in Hz for computing VLF (very low frequency) power in RR spectrum.'), ...
         'LFRange', ...
         getRules([0.04, 0.15], {'numeric'}, {'positive', 'row', 'size', [1, 2]}, ...
        'Range in Hz for computing LF (low frequency) power in RR spectrum.'), ...
        'HFRange', ...
         getRules([0.15, 0.4], {'numeric'}, {'positive', 'row', 'size', [1, 2]}, ...
        'Range in Hz for computing HF (high frequency) power in RR spectrum.') ...
     );
end

function s = getRules(value, classes, attributes, description)
% Construct the default structure
s = struct('value', [], 'classes', [], ...
    'attributes', [], 'description', []);
s.value = value;
s.classes = classes;
s.attributes = attributes;
s.description = description;
end