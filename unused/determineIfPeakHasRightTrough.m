    function tVal = determineIfPeakHasRightTrough(ekgInterval, qrsFrames, threshold)
        %%
        % Determine if the value at the peak is actually a peak.
        % Parameters:
        %    beatIdx   the index of the peak
        %%
        
        % get the negation of the ekg signal from the inner beat's index
        % to the last beat's index
        tVal = [];
        [endFrame, ~] = min([1 + 2*qrsFrames, length(ekgInterval)]);
        negsignal = -ekgInterval(2:endFrame);
        if length(negsignal) < 3
            return;
        end
        [tVal, tLocs] = findpeaks(negsignal, 'SortStr', 'descend');
        if isempty(tLocs) || tVal(1) < threshold || tLocs(1) > qrsFrames
            tVal = [];
        else
            tVal = tVal(1);
        end
%         endFrame =  min(length(ekg), beatFrame + qrsFrames*2);
%         negSignal = -ekg(beatFrame:endFrame);
%         valid = false;
%         if length(negSignal) < 3
%             return;
%         end
%         
%         [sVal, sLocs] = findpeaks(double(negSignal), 'SortStr', 'descend');
%         if ~isempty(sLocs) && -sVal(1) < threshold 
%             valid = true;
%         end
%     end
