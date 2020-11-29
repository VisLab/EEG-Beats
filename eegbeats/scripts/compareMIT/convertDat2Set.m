data = dir('./mit/*.dat'); 
numDatFiles = length(data);
if numDatFiles == 0
    return;
end

%% %convert .dat to .set stucture
for i = 1:numDatFiles
    %get num for new .set name
    fileNum = regexp(data(i).name,'(\d+)','match');
    setFile = strcat(fileNum,'.set');
    setFile = convertStringsToChars(string(setFile));
    
    fileName = strcat('./',data(i).name);
    
    %run
    [sig, Fs, tm] = rdsamp(fileName, 1);

    %struct for EEG
    EEG = eeg_emptyset();

    %fill in struct then save
    EEG.setname = strcat('MITDB-',string(fileNum));
    EEG.filename = setFile;
    EEG.filepath = 'C:\Users\nikki\OneDrive\Desktop\HeartRepository\set\';
    EEG.nbchan = 1;
    EEG.trials = 1;
    EEG.pnts = length(sig);
    EEG.srate = Fs;
    EEG.xmin = 0;
    EEG.xmax = (EEG.pnts-1)/EEG.srate;
    EEG.times = transpose(tm*1000);
    EEG.data = transpose(sig);
    EEG.ref = 'common';
    EEG.chaninfo.nodedir = '+X';
    EEG.chanlocs = struct('labels','EKG','type','EKG','theta',NaN,...
                           'radius',NaN,'X',NaN,'Y',NaN,'Z',NaN,...
                           'sph_theta',NaN,'sph_phi',NaN,'sph_radius',NaN,...
                           'urchan',1,'ref',NaN,'sph_theta_besa',NaN,'sph_phi_besa',NaN);
                       

    %save .set file                  
    save(strcat('./set/',setFile),'EEG');
end
