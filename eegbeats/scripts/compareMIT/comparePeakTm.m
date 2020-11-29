setDir = dir('./set/*.set'); 
mitDir = './mit/';
newFile = ([pwd filesep 'compareInfo.mat']);

numDatFiles = length(setDir);
if numDatFiles == 0
    return;
end

peakCompare = struct('session',NaN,'filePath',NaN,...
                         'peaksEB',NaN,'peaksMIT',NaN,'numMatched',NaN,'numUnmatchedInEB',NaN,...
                         'numUnmatchedInMIT',NaN,'countsDistFromEB',NaN,'countsDistFromMIT',NaN);
peakCompare(numDatFiles) = peakCompare ;                 

%% %convert to .set stucture
for i = 1:numDatFiles
    
    %get num for new .set name
    fileNum = regexp(setDir(i).name,'(\d+)','match');
    setFile = convertStringsToChars(string(setDir(i).name));
    setFile = strcat('./set/',setFile);

    % get peakFrames from EEGBeats
    EEG = pop_loadset(setFile);
    params = struct();
    params.doPlot = 0;
    [ekgPeaks, params] = eeg_beats(EEG, params);

    %load their peakFrames
    fileName = convertStringsToChars(string(strcat(mitDir,fileNum)));
    ann = rdann(fileName,'atr',[],1);
    ann = transpose(ann);

    %convert to times 
    eegbeatsTm = ekgPeaks.peakFrames(1:length(ekgPeaks.peakFrames)-1)/128;
    mitTm = ann(1:length(ann)-1)/360; 
    
    
    %compare each file
    peakCompare(i).session = fileNum;
    peakCompare(i).filePath = fileName;
    peakCompare(i) = compareTm(peakCompare(i),eegbeatsTm, mitTm);
    
    
    
    

end

save(newFile, 'peakCompare');

function peakCompare = compareTm(peakCompare,peaksEB,peaksMIT)
    
    
    %% Compute the distances and Find the events that are matched 
    
   
    dMat = pdist2(peaksEB(:), peaksMIT(:));
    [minValues2EB,~] = min(dMat, [], 1);
    [minValues2MIT,~] = min(dMat, [], 2);
    
    
    frameDisEB = round(minValues2EB*128);
    frameDisMIT = round(minValues2MIT*128);
    
    peakCompare.peaksEB = peaksEB;
    peakCompare.peaksMIT = peaksMIT;
    peakCompare.numMatched = length(intersect(peaksEB(:), peaksMIT(:)));
    peakCompare.numUnmatchedInEB = length(setdiff(peaksEB(:), peaksMIT(:)));
    peakCompare.numUnmatchedInMIT = length(setdiff(peaksMIT(:), peaksEB(:)));
    peakCompare.countsDistFromEB = countUnique(frameDisMIT);
    peakCompare.countsDistFromMIT = countUnique(frameDisEB);
end



%% Plot
% EEGBEATS
% figure;
% plot(ekgPeaks.ekg);
% hold on;
% p1 = plot(ekgPeaks.peakFrames,ekgPeaks.ekg(ekgPeaks.peakFrames),'xk');
% 
% MITDB
% figure
% plot(EEG.data);
% hold on;
% p2 = plot(ann,EEG.data(ann),'-o');
