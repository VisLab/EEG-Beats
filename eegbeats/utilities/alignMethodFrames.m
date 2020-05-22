function [peakFrames, peakTwoFrames] = alignMethodFrames(ekg, peakFrames, peakTwoFrames, minRRFrames)   


    peakMask = zeros(1, length(ekg));
    peakTwoMask = peakMask;
    peakMask(peakFrames) = 1;
    
    peakTwoMask(peakTwoFrames) = 2;
    peakAllMask = peakMask + peakTwoMask;
    peakAll = find(peakAllMask > 0);
    for m = 1:length(peakAll) - 1
        p1 = peakAll(m);
        p2 = peakAll(m + 1);
        if peakAllMask(p1) == 3 || peakAllMask(p1) == 0 || ...
           peakAllMask(p2) == 3 || peakAllMask(p2) == 0 || ...
           peakAllMask(p1) == peakAllMask(p2) || ...
           p1 == p2 || p2 - p1  >= minRRFrames
            continue;
        end
        if ekg(p1) > ekg(p2)
            peakAllMask(p2) = 0;
            peakAllMask(p1) = 3;
        else
            peakAllMask(p1) = 0;
            peakAllMask(p2) = 3;
        end
    end
    baseFrames = 1:length(ekg);
    peakFrames = baseFrames(peakAllMask == 3 | peakAllMask == 1);
    peakTwoFrames = baseFrames(peakAllMask == 3 | peakAllMask == 2);