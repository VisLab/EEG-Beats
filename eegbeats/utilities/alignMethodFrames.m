function [peakFrames, peakTwoFrames] = alignMethodFrames(ekg, peakFrames, ...
                                                peakTwoFrames, minRRFrames)   
%% Align peak frames from alternative peak frame calculations on same data
%
%  Parameters:
%     ekg           1-D array containing ekg signal
%     peakFrames    1-D array containing peak frame positions for method 1
%     peakTwoFrames 1-D array containing peak frame positions for method 2
%     minRRFrames   minimum number of frames allowed between valid peaks
%
% Method uses a count mask: 
%  0(no peak), 1 (peak for 1), 2 (peak for 2), 3(peak for both)
%
%% Set the masks
    peakMask = zeros(1, length(ekg));
    peakTwoMask = peakMask;
    peakMask(peakFrames) = 1;
    peakTwoMask(peakTwoFrames) = 2;
    peakAllMask = peakMask + peakTwoMask;
    peakAll = find(peakAllMask > 0);
    for m = 1:length(peakAll) - 1
        p1 = peakAll(m);
        p2 = peakAll(m + 1);
        %% No peaks to adjust if not close
        if peakAllMask(p1) == 3 || peakAllMask(p1) == 0 || ...
           peakAllMask(p2) == 3 || peakAllMask(p2) == 0 || ...
           peakAllMask(p1) == peakAllMask(p2) || ...
           p1 == p2 || p2 - p1  >= minRRFrames
            continue;
        end
        %% If peaks from two methods close by adjust to one with largest ekg
        if ekg(p1) > ekg(p2)
            peakAllMask(p2) = 0;
            peakAllMask(p1) = 3;
        else
            peakAllMask(p1) = 0;
            peakAllMask(p2) = 3;
        end
    end
    baseFrames = 1:length(ekg);
    
    %% Keep only unmatched or aligned peaks
    peakFrames = baseFrames(peakAllMask == 3 | peakAllMask == 1);
    peakTwoFrames = baseFrames(peakAllMask == 3 | peakAllMask == 2);