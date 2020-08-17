function [currentVersion, changeLog, markdown] = getEEGBeatsVersion()
%% Get the current EEG-Beats version and the markdown for the changelog.
    changeLog = getChangeLog();
    currentVersion = ['eegbeats' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()

    changeLog(2) = ...
     struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');

    changeLog(2).version = '1.1';
    changeLog(2).status = 'Unreleased';
    changeLog(2).date = '8/17/2020';
    changeLog(2).changes = {'EEG-Beats with EEGLAB plugin gui'};


    changeLog(1).version = '1.0';
    changeLog(1).status = 'Released';
    changeLog(1).date = '7/28/2020';
    changeLog(1).changes = { ...
       'Initial release of EEG-Beats sans EEGLAB plugin gui'};
end

function markdown = getMarkdown(changeLog)
   markdown = '';
   for k = length(changeLog):-1:1
       tString = sprintf('Version %s %s %s\n', changeLog(k).version, ...
           changeLog(k).status, changeLog(k).date);
       changes = changeLog(k).changes;
       for j = 1:length(changes)
           cString = sprintf('* %s\n', changes{j});
           tString = [tString cString]; %#ok<*AGROW>
       end
       markdown = [markdown tString sprintf('  \n')];
   end
end