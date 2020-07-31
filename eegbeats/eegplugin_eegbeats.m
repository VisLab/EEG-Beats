% eegplugin_eegbeats() - a wrapper to eegBeats, which process an EKG signal
% 
% Usage:
%   >> eegplugin_eegBeats(fig, try_strings, catch_strings);
%
%   see also: prepPipeline

% Author: Kay Robbins, Brenda Trejo, Sabrina Mosher, Nikki Thanapaisal

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
%

function vers = eegplugin_eegbeats(fig, trystrs, catchstrs) 
%% The GUI for this function is in progress

%% Add path to eegbeats subdirectories if not in the list
myPath = fileparts(mfilename('fullpath'));
addpath(fullfile(myPath, 'utilities'));
vers = getEEGBeatsVersion(); 

% create menu
comprep = [trystrs.no_check '[ekgPeaks, LASTCOM] = pop_eegbeats(EEG);' catchstrs.new_and_hist];
menu = findobj(fig, 'tag', 'tools');
uimenu( menu, 'Label', 'Run eegbeats to get heartbeats from EKG', 'callback', comprep, ...
    'separator', 'on');