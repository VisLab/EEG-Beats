%% Get the EEG data, load it, filter the HR, and save the HR rate
% Parameters:
%   loadPath        the path to load the data from
%   saveDir         the directory to load the data to.
%%
function convertEegToEkg(loadPath, saveDir)
    % Create the directory if it does not exist
    if ~mkdir(saveDir)
        print('Invalid save directory');
    end
    
    if isfolder(loadPath)
        filepath = fullfile(loadPath, {'*.set'} );
        filename = dir(filepath{1});
        
        % Run through all the filenames
        for i = 1:length(filename)
            singleFullPath = [saveDir filesep filename(i).name];
            % Don't do anything if it already exists
            if exist(singleFullPath, 'file')
                fprintf('Error: File already exists: %s\n', singleFullPath);
                continue;
            end
            eeg = pop_loadset([loadPath filesep filename(i).name]);
            eeg = getEkgFromEeg(eeg, 128);
            pop_saveset(eeg, [saveDir filesep filename(i).name]);
        end
    else
        % Skip if already done
        [~, name, ext] = fileparts(loadPath);
        if exist([saveDir filesep name '.set'], 'file')
        	fprintf('Error: File already exists: %s\n', loadPath);
            return;
        end
        
        % Process the data
        eeg = pop_loadset(loadPath);
        eeg = getEkgFromEeg(eeg, 128);
        pop_saveset(eeg, [saveDir filesep name])% '.' ext]);
    end
end

