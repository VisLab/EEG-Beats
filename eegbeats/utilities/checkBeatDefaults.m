function [structOut, errors] = checkBeatDefaults(structIn, structOut, defaults)
% Check structIn input parameters against defaults fields of structOut
%
% Parameters:
%    structIn     Parameter structure to be checked
%    structOut    Base output structure for parameters.
%    defaults     Default information
%
% Note:  structOut contains fields that will always be there.
%% Set up the checks
errors = cell(0);
fNames = fieldnames(defaults);
for k = 1:length(fNames)
    try
       nextValue = getBeatStructureParameters(structIn, fNames{k}, ...
                                          defaults.(fNames{k}).value);
       validateattributes(nextValue, defaults.(fNames{k}).classes, ...
                         defaults.(fNames{k}).attributes);
       structOut.(fNames{k}) = nextValue;
    catch mex
        errors{end+1} = [fNames{k} ' parameter value invalid: ' mex.message]; %#ok<AGROW>
    end
end