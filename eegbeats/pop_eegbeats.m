% pop_eegbeats() - analyzes heart rate variability from an ekg/eeg sensor
%
% Usage:
%   >>   [ekgPeaks, ibiInfo, com] = pop_eegbeats(INEEG, params);
%
% Inputs:
%   INEEG   - input EEG dataset
%   params  - (optional) structure with parameters to override defaults
%
% Outputs:
%   ekgPeaks - structure containing the extracted ekg and detected beats
%   ibiInfo  - structure containing interbeat interval metrics 
%
% See also:
%   runGetHeartBeats, getHeartBeats, EEGLAB

% Copyright (C) 2020  Kay Robbins,Brenda Trejo, Sabrina Mosher, Nikki Thanapaisal
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function [ekgPeaks, rrInfo, params, com] = pop_eegbeats(EEG, params)
%% EEGLAB function to call entire pipeline on one EEG dataset. 
    com = ''; % Return something if user presses the cancel button
    [ekgPeaks, rrInfo] = getEmptyBeatStructs();
    okay = true;
    
%% Pop up a dialog if needed
    if nargin < 1  %% display help if not enough arguments
        help(mfilename);
        return;
    elseif isempty(EEG.data)
        warndlg2('The EEG file must be loaded first', ...
            [mfilename '(): Dataset is empty!'])
        return
    elseif size(EEG.data, 3) > 1 % data is epoched
        warndlg2('eegbeats requires continuous (unepoched) EEG data', ...
            [mfilename '(): Dataset is epoched!'])
        return
    elseif nargin < 2
       [params, okay] = dlg_eegbeats(getBeatDefaults());
       [params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
       if ~isempty(errors)
           warndlg2(['Invalid parameters: ' convertCell2Str(errors)]);
           return;
       end
    end

    %% Return if user pressed cancel or if bad parameters
    if (~okay) 
        return;
    end

%% Check the parameters against the defaults
[params, errors] = checkBeatDefaults(params, params, getBeatDefaults());
if ~isempty(errors)
    warning(['pop_eegbeats has invalid input parameters' convertCell2Str(errors)]);
    return;
end
    
theName = '';
if isfield(params, 'fileName') && ~isempty(params.fileName)
    [~, theName] = fileparts(params.fileName);
elseif ~isfield(params, 'fileName') && ~isempty(EEG.filename)
    [~, theName] = fileparts(EEG.filename);
    params.fileName = theName;
elseif ~isfield(params, 'fileName') && ~isempty(EEG.setname)
    [~, theName] = fileparts(EEG.setname);
    params.fileName = theName;
elseif ~isfield(params, 'fileName')
    params.fileName = 'unknown';
end


%% Now get the peaks and save things if necessary
[ekgPeaks, params] = eeg_beats(EEG, params);
[rrInfo, params] = eeg_ekgstats(ekgPeaks, params);

if ~isempty(params.fileDir)
    if ~exist(params.fileDir, 'dir')
            mkdir(params.fileDir);
     end
     save([params.fileDir filesep theName '_ekgPeaks.mat'], 'ekgPeaks', 'params', '-v7.3');
     save([params.fileDir filesep theName '_rrInfo.mat'], 'rrInfo', 'params', '-v7.3');
end



%% Now set the com string
com = sprintf('[ekgPeaks, rrInfo, params] = pop_eegbeats(%s, %s);', ...
               inputname(1), struct2str(params));
end % pop_eegbeats