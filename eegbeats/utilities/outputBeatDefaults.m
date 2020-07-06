function [] = outputBeatDefaults(fd)

if nargin < 1
    fd = 1;
end

defaults = getBeatDefaults();
params = struct();
params = checkBeatDefaults(params, params, defaults);

fNames = fieldnames(params);
numFields = length(fNames);

%% Now output
fprintf(fd, 'eegbeat defaults:\n');
for k = 1:numFields
    dValue = defaults.(fNames{k});
    fprintf(fd, '\t%s: [%s]\n', fNames{k}, num2str(dValue.value));
    fprintf(fd, '\t\t%s', dValue.description);
    if ~isempty(dValue.classes)
        fprintf(fd, '\n\t\t[classes: ');
        for m = 1:length(dValue.classes)
            fprintf(fd, '%s ', num2str(dValue.classes{m}));
        end
        fprintf(']');
    end
    if ~isempty(dValue.attributes)
        fprintf(fd, '\n\t\t[attributes: ');
        for m = 1:length(dValue.attributes)
            fprintf(fd, '%s ', num2str(dValue.attributes{m}));
        end
        fprintf(']');
    end
    fprintf(fd, '\n');
end


