function [currentVersion, changeLog, markdown] = getBeatVersion()

    changeLog = getChangeLog();
    currentVersion = ['eegbeats' changeLog(end).version]; 
    markdown = getMarkdown(changeLog);
end

function changeLog = getChangeLog()
   changeLog(1) = ...
     struct('version', '0', 'status', 'Unreleased', 'date', '', 'changes', '');

    changeLog(1).version = '1.0';
    changeLog(1).status = 'Unreleased';
    changeLog(1).date = '4/19/2020';
    changeLog(1).changes = { ...
       'Initial organization of eegbeats as an EEGLAB plugin'};
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