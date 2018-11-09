function [indicators] = getIBIIndicators(rrIntervals)
%% Given a specific ibi generate the indicators
    if(iscell(rrIntervals))
        rrIntervals = cell2mat(rrIntervals);
    end
    
    N = length(rrIntervals);
    dt = max(rrIntervals)-min(rrIntervals);
    binWidth = 1/128;
    nBins = round(dt/binWidth);
    [nout, ~] = histcounts(rrIntervals, nBins ,'BinWidth', binWidth);
    
    meanRR = mean(rrIntervals); %s
    SDNN = std(rrIntervals); %s
    RMSSD = sqrt((sum(power(diff(rrIntervals),2)))/(N-1)); %s
    NN50 = sum(abs(diff(rrIntervals)) > .05); %beats
    pNN50 = (NN50/(N-1))*100; % %
    if isempty(rrIntervals) || isempty(nout) 
        RRT = NaN;
    else
        RRT = length(rrIntervals)/max(nout); %= N/(number of RR intervals in modal bin)
    end
    %TINN = tinn(nBins,nout,xout);
    indicators = [meanRR, SDNN, RMSSD, NN50, pNN50, RRT];
    
end