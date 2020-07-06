function values = getEBValuesFromStructure(rrInfo, fieldName)

values = nan(length(rrInfo), 1);
for k = 1:length(rrInfo)
    if ~isstruct(rrInfo(k).blockValues) && isnan(rrInfo(k).blockValues)
        continue;
    end
    theValue = rrInfo(k).blockValues(1);
    values(k) = theValue.(fieldName);
end