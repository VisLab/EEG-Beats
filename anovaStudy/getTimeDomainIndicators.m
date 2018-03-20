function values = getTimeDomainIndicators(rrIntervals)
    % This function takes in the interval of the array and calculates
    % the parameters for that interval. 
    
   
    
    if(iscell(rrIntervals))
        rrIntervals = cell2mat(rrIntervals);
    end
    
    N = length(rrIntervals);
    dt = max(rrIntervals)-min(rrIntervals);
    binWidth = 1/128;
    nBins = round(dt/binWidth);
    [nout, edges] = histcounts(rrIntervals, nBins ,'BinWidth', binWidth);
    xout = edges + (binWidth/2);
    
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
    values = [meanRR, SDNN, RMSSD, NN50, pNN50, RRT];
    
    function pt_ans = tinn(rrIntervals, binWidth, nout, xout)
    end
end