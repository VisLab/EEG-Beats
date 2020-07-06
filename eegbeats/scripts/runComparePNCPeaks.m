%% Compare peaks from EEG-Beats (EB) and PhysioNet Cardiovascular Signal Toolbox (PNC)

%% Set the filenames for the comparison
ekgFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\ekgPeaks.mat';
pncFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\physionetInfo.mat';
compareFile = 'D:\TestData\NCTU_RWN_VDE_Heart_Data\EBPNCPeakCompare.mat';

%% Should we remove low and high amplitude peaks from EB before?
removeEBBad = false;

%% Load the heartbeat peaks for both tools
temp = load(ekgFile);
ekgPeaks = temp.ekgPeaks;
params = temp.params;
temp = load(pncFile);
pncInfo = temp.physioInfo;
numFiles = length(ekgPeaks);
%% Create the template
peakCompare = struct('fileName', NaN, 'numPeaksEB', 0, ...
         'numOutOfRangePeaksEB', 0, 'numPeaksPNC', 0, ...
         'numMatched', 0, 'numUnmatchedInEB', 0, 'numUnmatchedInPNC', 0, ...
         'countsDistFromEB', NaN, 'countsDistFromPNC', NaN);
peakCompare(numFiles) = peakCompare(1);

%% Now step through
for k = 1:numFiles
    peakCompare(k) = peakCompare(end);
    peakCompare(k).fileName = ekgPeaks(k).fileName;
    if isscalar(ekgPeaks(k).ekg) && isnan(ekgPeaks(k).ekg)
        fprintf('%d:%s skipped because no EKG\n', k, ekgPeaks(k).fileName);
        continue;
    end
    if isscalar(ekgPeaks(k).peakFrames) && isnan(ekgPeaks(k).peakFrames)
        fprintf('%d:%s has no EB peaks\n', k, ekgPeaks(k).fileName);
        peaksEB = [];
    else
        peaksEB = ekgPeaks(k).peakFrames;
    end
    if ~isstruct(pncInfo(k).pnPeakInfo) && isnan(pncInfo(k).pnPeakInfo)
        fprintf('%d:%s has no PNC peaks\n', k, ekgPeaks(k).fileName);
        peaksPNC = [];
    else
        peaksPNC = pncInfo(k).pnPeakInfo.peaks;
    end
    peakCompare(k).numPeaksEB = length(peaksEB);
    peakCompare(k).numPeaksPNC = length(peaksPNC);
    outOfRangePeaks = union(ekgPeaks(k).lowAmplitudePeaks, ekgPeaks(k).highAmplitudePeaks);
    peakCompare(k).numOutOfRangePeaksEB = length(outOfRangePeaks);
    
    if removeEBBad
        peaksEB = setdiff(peaksEB,  peakCompare(k).numOutOfRangePeaksEB);
    end
    
    if peakCompare(k).numPeaksEB == 0 || peakCompare(k).numPeaksPNC == 0
       fprintf('%d:%s has no peaks for either EB or PNC...skipping\n', ...
               k, ekgPeaks(k).fileName); 
       continue;
    end
%% Compute the distances
    dMat = pdist2(peaksEB(:), peaksPNC(:));

%% Find the events that are matched to within frameLimit
    [minValues2PNC, minInd2PNC] = min(dMat, [], 2);
    [minValues2EB, minInd2EB] = min(dMat, [], 1);

%% Number exact match
    peakCompare(k).numMatched = length(intersect(peaksEB(:), peaksPNC(:)));
    peakCompare(k).numUnmatchedInEB = length(setdiff(peaksEB(:), peaksPNC(:)));
    peakCompare(k).numUnmatchedInPNC = length(setdiff(peaksPNC(:), peaksEB(:)));
    peakCompare(k).countsDistFromEB = countUnique(minValues2PNC);
    peakCompare(k).countsDistFromPNC = countUnique(minValues2EB);
 
end

%% Output the report
ebNumPeaks = cell2mat({peakCompare.numPeaksEB});
pncNumPeaks = cell2mat({peakCompare.numPeaksPNC});
fprintf('Number of datasets with peaks for EB: %d\n', sum(ebNumPeaks ~= 0));
fprintf('Number of datasets with peaks for PNC: %d\n', sum(pncNumPeaks ~= 0));
comboMask = ebNumPeaks~= 0 & pncNumPeaks ~= 0;
fprintf('Number of datasets in which both have peaks: %d\n', sum(comboMask));
rCompare = peakCompare(comboMask);
rebPeaks = ebNumPeaks(comboMask);
rpncPeaks = pncNumPeaks(comboMask);
fprintf('Number peaks in EB: %d\n', sum(rebPeaks));
fprintf('Number peaks in PNC: %d\n', sum(rpncPeaks));
runmatchEB = cell2mat({rCompare.numUnmatchedInEB});
runmatchPNC = cell2mat({rCompare.numUnmatchedInPNC});
fprintf('Number unmatched peaks in EB: %d\n', sum(runmatchEB));
fprintf('Number unmatchedpeaks in PNC: %d\n', sum(runmatchPNC));

cLimits = [0, 0; 1, 1; 2, 2; 3, 3; 4, Inf];
counts = zeros(size(cLimits, 1), 2);  % Rows 0, 1, 2, 3, 4to10, >10

for k = 1:length(rCompare)
    countsEB = rCompare(k).countsDistFromEB;
    countsPNC = rCompare(k).countsDistFromPNC;
    for m = 1:size(cLimits, 1)
        maskEB = cLimits(m, 1) <= countsEB(:, 1) & countsEB(:, 1) <= cLimits(m, 2);
        counts(m, 1) = counts(m, 1) + sum(countsEB(maskEB, 2));
        maskPNC = cLimits(m, 1) <= countsPNC(:, 1) & countsPNC(:, 1) <= cLimits(m, 2);
        counts(m, 2) = counts(m, 2) + sum(countsPNC(maskPNC, 2));
    end
end
    
%% Now output reports
% %% Save the file
% %save(compareFile, 'fields', 'compareInfo', '-v7.3');