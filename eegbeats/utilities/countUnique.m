function uniqueCounts = countUnique(values)
% Return an array with unique values in column 1 and counts in column 2

uValues = unique(values);
uniqueCounts = zeros(length(uValues), 2);
uniqueCounts(:, 1) = uValues(:);
for k = 1:length(uValues)
    uniqueCounts(k, 2) = sum(values == uValues(k));
end
