function str = cell2str(cellArray)

str = '';
if isempty(cellArray)
    return;
end
str = ['[' cellArray{1} ']'];
for k = 2:length(cellArray)
    str = [str ' [' cellArray{k} ']']; %#ok<*AGROW>
end