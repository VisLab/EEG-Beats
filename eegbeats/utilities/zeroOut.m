   function ekg = zeroOut(ekg, peakFrame, qrsHalfFrames)
     %% Zero out the surrounding signal around suspected R peaks.
     %
     %  Parameters:
     %      ekg         The EKG signal prior to zeroing out.
     %      peaksIdx    An array of suspected R peaks in samples.
     %      ekg         (output) The EKG signal that has been zeroed out around
     %                  the R peaks.
     %
     %  Example:
     %      ekg = zeroOut(ekg, peaksidx, below, above, srate)
     %%
 
     firstIdx = max(1, peakFrame - qrsHalfFrames); %Max between 1 and tb-below
     lastIdx = min(peakFrame + qrsHalfFrames, length(ekg)); 
     ekg(firstIdx: lastIdx) = 0;
 