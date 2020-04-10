 function tooClose = isTooClose(firstFrame, innerFrame, lastFrame, minFrames)
    %% Determine if the innerBeatBaseIdx meets the criteria for an R peak.

        % innerBeatBaseIdx is two close to firstBeatIdx or lastBeatIdx
        tooClose =  firstFrame + minFrames > innerFrame || ...
                    lastFrame - minFrames < innerFrame;
   

    end