%% function [eeg] = getEkgFromEeg(eeg, srate)
% convert and eeg to the resulting ekg
function [eeg] = getEkgFromEeg(eeg, minSrate)
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
    eeg = pop_eegfiltnew(eeg, 2, 20);%, 660, 0, [], 0);
end

