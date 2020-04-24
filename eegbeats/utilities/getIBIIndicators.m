function [indicators] = getIBIIndicators(ibiIntervals)
%% Given a specific ibi generate the indicators
% Parameters:
%       the ibi signal
% Return value:
%       the different statistical indicators as a list of size 6
%       containing the following in order:
%           mean std rmssd nn50
%           pnn50 rrt
%%
 
    
    N = length(ibiIntervals);
    dt = max(ibiIntervals)-min(ibiIntervals);
    binWidth = 1/128;
    nBins = round(dt/binWidth);
    [nout, ~] = histcounts(ibiIntervals, nBins ,'BinWidth', binWidth);
    
    meanRR = mean(ibiIntervals); %s
    SDNN = std(ibiIntervals); %s
    RMSSD = sqrt((sum(power(diff(ibiIntervals),2)))/(N-1)); %s
    NN50 = sum(abs(diff(ibiIntervals)) > .05); %beats
    pNN50 = (NN50/(N-1))*100; % %
    if isempty(ibiIntervals) || isempty(nout) 
        RRT = NaN;
    else
        RRT = length(ibiIntervals)/max(nout); %= N/(number of RR intervals in modal bin)
    end
    %TINN = tinn(nBins,nout,xout);
    indicators = [meanRR, SDNN, RMSSD, NN50, pNN50, RRT];
    
end