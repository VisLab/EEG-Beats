function [peakCombined, peakLeft] = combineMethodPeaks(peakFrames, peakTwoFrames, minIbiFrames)     

    if length(peakFrames) < length(peakTwoFrames)
        peakCombined = peakTwoFrames;
    else
        peakCombined = peakFrames;
    end
    peakRest = setdiff(union(peakFrames, peakTwoFrames), peakCombined);
    peakLeft = [];
    if isempty(peakRest)
        return;
    end
    
   
    %% Take care of peaks at the beginning
    lastInd = find(peakRest < peakCombined(1), 1, 'last');
    if ~isempty(lastInd)
        frontPeaks = peakRest(1:lastInd);
        peakRest = peakRest(lastInd + 1:end);
        for k = length(frontPeaks):1
            if peakCombined(1) - frontPeaks(k) > minIbiFrames
                peakCombined = [frontPeaks(k) peakCombined];
            else
                peakLeft = [peakLeft frontPeaks(k)];
            end
        end
    end   
     %% Take care of the peaks at the end
     firstInd = find(peakRest > peakCombined(end), 1, 'first');
     if ~isempty(firstInd)
        backPeaks = peakRest(firstInd:end);
        peakRest = peakRest(1:firstInd - 1);
        for k = 1: length(backPeaks)
            if backPeaks(k) -  peakCombined(end) >=  minIbiFrames
                peakCombined = [peakCombined, backPeaks(k)]; %#ok<*AGROW>
            else
                peakLeft = [peakLeft backPeaks(k)];
            end
        end
     end   
     
     if isempty(peakRest)
         return;
     end
     
     %% Now deal with what is left
     for k = 1:length(peakRest)
         lastInd = find(peakCombined > peakRest(k), 1, 'first');
         if isempty(lastInd)
             continue;
         end
         if peakRest(k) - peakCombined(lastInd - 1) >= minIbiFrames && ...
             peakCombined(lastInd) - peakRest(k) >= minIbiFrames
             peakCombined = [peakCombined(1:lastInd - 1), peakRest(k) ...       
                             peakCombined(lastInd:end)];
         else
             peakLeft = [peakLeft peakRest(k)];
         end
     end
     
     peakLeft = sort(peakLeft);
