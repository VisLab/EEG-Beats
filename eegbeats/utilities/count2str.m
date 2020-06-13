function mString = count2str(minValues)

mString = '';
uValues = unique(minValues);
for k = 1:length(uValues)
    mString = [mString ' ' num2str(uValues(k)) ':' ...
               num2str(sum(minValues == uValues(k)))]; %#ok<*AGROW>
end