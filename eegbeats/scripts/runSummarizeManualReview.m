%% This script counts how many first blocks were able to have computations.

%compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data2/EBPNCCompare.mat';
reviewFile = 'D:\Papers\Current\Heart\ekgPeaksReducedCombined.xlsx';
shouldFlip = [221, 226, 239, 260, 262];
shouldNotFlip = [293, 294, 295, 296, 298];
badFiles = [114, 306, 355, 498, 500, 587, 588, 589, 761, 763];
sheets = {'S001-100', 'S101-200', 'S201-300', 'S301-400', ...
          'S401-500', 'S501-600', 'S601-700', 'S701-800', 'S801-855'};
%% Create an import options object for the file
opts = detectImportOptions(reviewFile);
opts.SelectedVariableNames = {'Sessions', 'Flip', 'Pass'};

T = cell(length(sheets), 1);
summary = [];
for k = 1:length(sheets)
    opts.Sheet = sheets{k};
    T{k} = readtable(reviewFile, opts, 'ReadVariableNames', true);
    summary = [summary; table2array(T{k})]; %#ok<*AGROW>
end

flipErrorMask = summary(:, 2) ~= 0;
badMask = summary(:, 3) > 3;
noErrorMask = summary(:, 3) == 1;
smallErrorMask = summary(:, 3) == 2;
largeErrorMask = summary(:, 3) == 3;
sessionsNoError = summary(noErrorMask & ~flipErrorMask & ~badMask, 1);
sessionsSmallErrors = summary(smallErrorMask & ~flipErrorMask & ~badMask, 1);
sessionsLargeErrors = summary(largeErrorMask & ~flipErrorMask & ~badMask, 1);
fprintf('Total files: %d\n', size(summary, 1));
fprintf('Total bad files: %d\n', sum(badMask));
fprintf('Total bad flip files: %d\n', sum(flipErrorMask));
fprintf('Total with no errors: %d\n', sum(noErrorMask));
fprintf('Total with a small number of errors: %d\n', sum(smallErrorMask));
fprintf('Total with a large number of errors: %d\n', sum(largeErrorMask));
