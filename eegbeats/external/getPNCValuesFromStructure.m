function values = getPNCValuesFromStructure(pncInfo, fieldName)

values = nan(length(pncInfo), 1);
for k = 1:length(pncInfo)
    if ~isstruct(pncInfo(k).pnRRMeasures) && isnan(pncInfo(k).pnRRMeasures)
        continue;
    end
    theValue = pncInfo(k).pnRRMeasures;
    values(k) = theValue.(fieldName);
end