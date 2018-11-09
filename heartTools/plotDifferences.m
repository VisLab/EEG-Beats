%% Plot the data and the output
function plotDifferences(eeg, brPeaks, name)
    % Set up t
    t = 1:length(eeg.data);
    t = (t-1)/eeg.srate;
    
    figure('Name', name);
    hold on;
    plot(t, eeg.data, 'black');
    brIdx = int64(brPeaks);
    %ptIdx = int64(ptPeaks);
    
    % plot pan tompkins
    %plot(t(ptIdx), eeg.data(ptIdx), 'b*');
    
    % plot brenda
    plot(t(brIdx), eeg.data(brIdx), 'r*');
    hold off;
end

