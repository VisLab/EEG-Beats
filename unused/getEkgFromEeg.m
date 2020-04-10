function [eeg] = getEkgFromEeg(eeg, minSrate, low, high)
%% Takes a given eeg signal and grabs and filters the ekg signal, returning
%  only the ekg signal
%  Parameters:
%       eeg         the eeg signal
%       minSrate    the minimum sampling rate
%       low         the low pass filter
%       high        the high pass filter
%  Return value:
%       the filtered ekg signal in an eeg struct
%%
    if size(eeg.data, 1) ~= 63
        eeg = [];
        return;
    end
    
    % Remove other channels and keep only the EKG data
    eeg.data = eeg.data(63,:);
    eeg.nbchan = 1;
    eeg.chanlocs = eeg.chanlocs(63);

    % Process the EEG data from a single dataset
    % If the sampling frequency is not 200, resample. 
    if eeg.srate > minSrate
        eeg = pop_resample(eeg, minSrate);
    end

    % Filter the data
    eeg = pop_eegfiltnew(eeg, low, high);%, 660, 0, [], 0);
end

