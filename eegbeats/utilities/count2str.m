function mString = count2str(minValues)
%% Return a string with the counts of unique values in minValues
mString = '';
uValues = unique(minValues);
for k = 1:length(uValues)
    mString = [mString ' ' num2str(uValues(k)) ':' ...
               num2str(sum(minValues == uValues(k)))]; %#ok<*AGROW>
end
