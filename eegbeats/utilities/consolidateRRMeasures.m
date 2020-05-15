function  [rrValues, rrPositions] = consolidateRRMeasures(rrInfo, rrType, rrMeasures)

rrValues = [];
rrPositions = [];

if ~isfield(rrInfo, rrType)
    warning('%s is not a field of rrInfo...skipping', rrType);
    return;
end

%% Get the positions of the items
for k = 1:length(rrInfo)
    theseValues = rrInfo(k).(rrType);
    if isempty(theseValues) || (~isstruct(theseValues) && isnan(theseValues)) 
        continue;
    end
    values = nan(length(theseValues), length(rrMeasures));
    for m = 1:length(rrMeasures)
        if ~isfield(theseValues, rrMeasures{m})
            continue;
        end
        rMeasure = cell2mat({theseValues.(rrMeasures{m})});
        values(:, m) = rMeasure(:);
    end
    rrValues = [rrValues; values]; %#ok<*AGROW>
    rrPositions = [rrPositions; repmat(k, length(theseValues), 1)];
end
