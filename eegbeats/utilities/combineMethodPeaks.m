function [peakCombined, peakLeft] = combineMethodPeaks(peakFrames, peakTwoFrames, minRRFrames)     
%% Combine peaks from two methods of getting peaks
%
% Parameters:
%    peakFrames      Array of peak frames from first method 
%    peakTwoFrames   Array of peak frames from second method 
%    minRRFrames     Minimum frames between peaks to consider distinct
%
% Note: This function is always called to merge peaks from single-peak and
% peak-trough strategies, although it may be used in other situations.
%
%% Choose the representation with most peaks as the baseline representation
    if length(peakFrames) < length(peakTwoFrames)
        peakCombined = peakTwoFrames;
    else
        peakCombined = peakFrames;
    end
    
%% See which peaks aren't in the baseline representation
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
            if peakCombined(1) - frontPeaks(k) > minRRFrames
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
            if backPeaks(k) -  peakCombined(end) >=  minRRFrames
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
         if peakRest(k) - peakCombined(lastInd - 1) >= minRRFrames && ...
             peakCombined(lastInd) - peakRest(k) >= minRRFrames
             peakCombined = [peakCombined(1:lastInd - 1), peakRest(k) ...       
                             peakCombined(lastInd:end)];
         else
             peakLeft = [peakLeft peakRest(k)];
         end
     end
     
     peakLeft = sort(peakLeft);
