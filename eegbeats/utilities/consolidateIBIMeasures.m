function  [values, positions] = consolidateIBIMeasures(ibiInfo, ibiType, ibiMeasure)

values = [];
positions = [];

if ~isfield(ibiInfo, ibiType)
    warning('%s is not a field of ibiInfo...skipping', ibiType);
    return;
end

for k = 1:length(ibiInfo)
    theseValues = ibiInfo(k).(ibiType);
    if isempty(theseValues)  || ...
      (~isstruct(theseValues) && isnan(theseValues)) || ...
      ~isfield(theseValues, ibiMeasure)
        continue;
    end
    if length(theseValues) == 1
        values = [values; theseValues.(ibiMeasure)]; %#ok<*AGROW>
        positions = [positions; k];
        continue;
    end
    nValues = nan(length(theseValues), 1);
    for n = 1:length(theseValues)
        nValues(n) = theseValues(n).(ibiMeasure);
    end
    values = [values; nValues(:)]; 
    positions = [positions; repmat(k, length(theseValues), 1)];
end