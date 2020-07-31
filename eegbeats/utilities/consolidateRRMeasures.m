function  [rrValues, rrPositions] = consolidateRRMeasures(rrInfo, rrType, rrMeasures)
%% Extract measure values and row number of structure from rrInfo struct
%
% Parameters:
%    rrInfo          The rrInfo structure produced by eeg_ekgstats
%    rrType          Either 'overallValues' or 'blockValues'
%    rrMeasures      Cell array with RR measure names
%
% Note: This function is used for statistical analysis and visualization, 
% where information is needed as vectors rather than structures.
%

%% Initialize
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
