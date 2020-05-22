%% Produce a table of counts

anovaFile = 'D:\TestData\NCTU_RWN_VDE_IBI_Analysis\anova\anova2BySubjectMeasures.mat';

rrScalingTypes = {'None', 'Subtract', 'Divide'};
%%
temp = load(anovaFile);
anova2Info = temp.anova2InfoBySubject;

%% 
sig = 0.05;
hSig = 0.001;

typeMask = strcmpi({anova2Info.type}, 'blockValues');
anova2Info = anova2Info(typeMask);
template = struct('measure', NaN, 'numValues', 0);
measures = unique({anova2Info.measure});
for s = 1:length(rrScalingTypes)
    template.(['Sig_' rrScalingTypes{s} '_1_p']) = 0;
    template.(['HSig_' rrScalingTypes{s} '_1_p']) = 0;
    template.(['Sig_' rrScalingTypes{s} '_2_p']) = 0;
    template.(['HSig_' rrScalingTypes{s} '_2_p']) = 0;
    template.(['Sig_' rrScalingTypes{s} '_1x2_p']) = 0;
    template.(['HSig_' rrScalingTypes{s} '_1x2_p']) = 0;
end

numMeasures = length(measures);
sigCount(1) = template;
sigCount(numMeasures + 1) = template;
for k = 1:length(measures)
    measureMask = strcmpi({anova2Info.measure}, measures{k});
    theseMeasures = anova2Info(measureMask);
    thisCount = template;
    thisCount.measure = measures{k};
    thisCount.numValues = length(theseMeasures);
    for s = 1:length(rrScalingTypes)
        theseValues = {theseMeasures.([rrScalingTypes{s} '_1_p'])};
        theseValues = cell2mat(theseValues);
        thisCount.(['Sig_' rrScalingTypes{s} '_1_p']) = sum(theseValues <= sig);
        thisCount.(['HSig_' rrScalingTypes{s} '_1_p']) = sum(theseValues <= hSig);
        
        theseValues = {theseMeasures.([rrScalingTypes{s} '_2_p'])};
        theseValues = cell2mat(theseValues);
        thisCount.(['Sig_' rrScalingTypes{s} '_2_p']) = sum(theseValues <= sig);
        thisCount.(['HSig_' rrScalingTypes{s} '_2_p']) = sum(theseValues <= hSig);
        
        theseValues = {theseMeasures.([rrScalingTypes{s} '_1x2_p'])};
        theseValues = cell2mat(theseValues);
        thisCount.(['Sig_' rrScalingTypes{s} '_1x2_p']) = sum(theseValues <= sig);
        thisCount.(['HSig_' rrScalingTypes{s} '_1x2_p']) = sum(theseValues <= hSig);
    sigCount(k) = thisCount;

    end
end
sigCount(numMeasures + 1).measure = 'Total count';
theFields = fieldnames(sigCount);
for k = 1:length(theFields)
    if strcmpi(theFields{k}, 'measure') 
        continue;
    end
    theseValues = cell2mat({sigCount.(theFields{k})});
    sigCount(end).(theFields{k}) = sum(theseValues);
end
    
    


    