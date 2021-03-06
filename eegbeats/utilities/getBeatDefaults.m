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
        ['Two-element vector specifying the frequency limits of the bandpass ' ...
        'filter used to process raw signals before detecting heartbeats.']), ...
        'srate', ...
        getRules(128, {'numeric'}, {'scalar', 'positive'}, ...
        'Frequency to resample raw ekg signal at before filtering'), ...
        'truncateThreshold', ...
        getRules(15, {'numeric'}, {'positive', 'scalar'}, ...
        ['Number of robust stds away from median to truncate ekg ' ...
        'before detecting heartbeats.']), ...
        'rrMaxMs', ...
        getRules(1500, {'numeric'}, {'positive', 'scalar'}, ...
        'Maximum number of milliseconds between peaks for valid RRs.'), ...
        'rrMinMs', ...
        getRules(500, {'numeric'}, {'positive', 'scalar'}, ...
        'Minimum number of milliseconds between peaks for valid RRs.'), ...
        'threshold', ...
        getRules(1.5, {'numeric'}, {'positive', 'scalar'}, ...
        ['Minimum heartbeat amplitude in units of robust stds away ' ...
        'from median signal.']), ...
        'qrsDurationMs', ...
        getRules(200, {'numeric'}, {'positive', 'scalar'}, ...
        'Maximum width of a heartbeat peak in milliseconds.'), ...
        'flipIntervalSeconds', ...
        getRules(2, {'numeric'}, {'positive', 'scalar'}, ...
        ['Length of subintervals in partition of signal to determine ' ...
        'dominant heartbeat direction.']), ...
        'flipDirection', ...
        getRules(0, {'numeric'}, {'integer', 'scalar'}, ...
        'If 0, use consensus algorithm. If 1 then flip. If -1, do not filp.'), ...
        'consensusIntervals', ...
        getRules(31, {'numeric'}, {'positive', 'scalar', 'integer'}, ...
        ['Number of intervals to partition the signal to determine ' ...
        'initial fenceposts.']), ...
        'maxPeakAmpRatio', ...
        getRules(2.0, {'numeric'}, {'nonnegative', 'scalar'}, ...
        ['Outlier peaks whose absolute amplitude is greater than ' ...
         'abs(maxPeakAmpRatio*median peak) are considered high amplitude.']), ...
        'minPeakAmpRatio', ...
        getRules(0.5, {'numeric'}, {'nonnegative', 'scalar'}, ...
        ['Outlier peaks whose absolute amplitude is less than '  ...
         'abs(minPeakAmpRatio*median peak)are considered low amp peaks.']), ...
        'maxWhisker', ...
        getRules(1.5, {'numeric'}, {'positive'}, ...
        ['Maximum whisker length for outlier peaks in units of iqr of' ...
        'peak distribution.']), ...
        'doPlot', ...
        getRules(true, {'logical'}, {}, ...
        'If true, produce a plot of EKG signal with heartbeats marked.'), ...
        'figureClip', ...
         getRules(3.0, {'numeric', 'positive'}, {}, ...
        'If not infinity (inf), plots are clipped at figureClip*iqr outside iqr.'), ...
        'figureVisibility', ...
        getRules('on', {'char'}, {}, ...
        ['If true, shows figures, otherwise creates but does not ' ...
        'display (for non-interactive mode).']), ...
        'figureClose', ...
        getRules(false, {'logical'}, {}, ...
        'If true, closes the figure after displaying/saving it.'), ...
        'fileDir', ...
        getRules('', {'char'}, {}, ...
        'If non-empty, base name(including path) of the file for saving.'), ...
        'figureDir', ...
         getRules('', {'char'}, {}, ...
        ['If not empty, base name (including path) to to save the plot ' ...
        'as a .fig and a .png file.']), ...
        'verbose', ...
        getRules(true, {'logical'}, {}, ...
        'If true, output intermediate algorithm information.'), ...
        'doRRMeasures', ...
         getRules(true, {'logical'}, {}, ...
        'If true, calculate RR measures.'), ...
        'rrsAroundOutlierAmpPeaks', ...
         getRules(1, {'numeric'}, {'integer', 'nonnegative'}, ...
        ['If > 0, exclude specified number of RRs on either side of peaks ' ...
         'that are too high or too low in RR measure calculation.']), ...
        'rrOutlierNeighborhood', ...
         getRules(5, {'numeric'}, {'integer', 'nonnegative'}, ...
        ['If > 0, total number of RR neighbors before and after ' ...
         '(balanced if possible) to use to calculate neighborhood average']), ...
        'rrPercentToBeOutlier', ...
         getRules(20, {'numeric'}, {'nonnegative'}, ...
        ['Percent above and below neighborhood average to designate RR ' ...
         'value as outlier (only used if RROutlierNeighborhood > 0']), ...
        'rrBlockMinutes', ...
         getRules(5, {'numeric'}, {'positive', 'scalar'}, ...
        'Block size in minutes for computing RR measures.'), ...
        'rrBlockStepMinutes', ...
         getRules(0.5, {'numeric'}, {'positive', 'scalar'}, ...
        'Minutes to slide window for computing RR measures.'), ...
        'detrendOrder', ...
         getRules(3, {'numeric'}, {'nonnegative', 'scalar', 'integer'}, ...
        ['Order of polynomial for detrending RRs or 0 if no detrend ' ...
        'prior to computing the measures.']), ...
        'removeOutOfRangeRRs', ...
         getRules(true, {'logical'}, {}, ...
        ['If true, remove RRs that are less than rrMinMs or greater ' ...
         ' than rrMaxMs when calculated RR measures.']), ...
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
         getRules([0.0033, 0.04], {'numeric'}, {'positive', 'row', 'size', [1, 2]}, ...
        ['Upper frequency bound in Hz for computing VLF (very low ' ...
        'frequency) power in RR spectrum.']), ...
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