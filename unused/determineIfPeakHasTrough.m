    function tVal = determineIfPeakHasTrough(negsignal, qrsFrames, threshold)
        %%
        % Determine if the value at the peak is actually a peak.
        % Parameters:
        %    beatIdx   the index of the peak
        %%
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        tVal = [];
        if length(negsignal) < 3
            return;
        end
        [tVal, tLocs] = findpeaks(negsignal, 'SortStr', 'descend');
        if isempty(tLocs) || tVal(1) < threshold || tLocs(1) > qrsFrames
            tVal = [];
        else
            tVal = tVal(1);
        end
