function [ A, B ] = findParameters(leftDir, rightDir )
%findParameters This function recieves two directories and reads in all of
%the files and returns two cell arrays for each directory with file names
%and parameters.
%   This function calculates all parameters for all files for the entire
%   time of the study. This function is best used when looking at big
%   picture changes between each data file. 

%% Create header file for cell array
header = {'File Name', 'meanRR', 'SDNN', 'RMSSD', 'NN50', 'pNN50', ...
    'RRT', 'TINN'};

    % Initialize array and create file paths.
    leftData = dir(fullfile(leftDir, '*.mat'));
    leftVariables = cell(length(leftData),8);
    leftVariables(1,:) = cellstr(header); % add in header to array
    
        %% Load files from first directory
    for i = 1: length(leftData);
        leftPath = fullfile(leftDir, leftData(i).name);
        load(leftPath);
        
        %% Create variables to be used in calculations
        rrIntervals = IBI_rawdata(2:end,2); 
        tEvents = IBI_rawdata(2:end,1);
        N = length(rrIntervals); % number of successive intervals
        rrIntervals = cell2mat (rrIntervals);
        dt = max(rrIntervals)-min(rrIntervals);
        binWidth = 1/128;
        nBins = dt/binWidth;
        [n, xout] = hist(rrIntervals, nBins);

        %% Calculate Time-Domain Parameters
        rrIntervals = cell2mat(rrIntervals);
        meanRR = mean(rrIntervals); %s
        SDNN = std(rrIntervals); %s
        RMSSD = sqrt((sum(power(diff(rrIntervals),2)))/(N-1)); %s
        NN50 = sum(abs(diff(rrIntervals)) > .05); %beats
        pNN50 = (NN50/(N-1))*100; % %
        RRT = length(rrIntervals)/max(n); 
             %= N/(number of RR intervals in modal bin)
        TINN = 0;

        %% Set up array to be returned
        leftVariables(i+1,:) = [cellstr(leftData(i).name), meanRR, ...
            SDNN, RMSSD, NN50, pNN50, RRT, TINN];
        A = leftVariables;
    end
    
    %% Initialize array and create file paths.
    rightData = dir(fullfile(rightDir, '*.mat'));
    rightVariables = cell(length(rightData),8);
    rightVariables(1,:) = cellstr(header);
    
        %% Load files from second directory
    for i = 1: length(rightData);
        rightPath = fullfile(rightDir, rightData(i).name);
        load(rightPath);
        
        %% Create variables to be used in calculations
        rrIntervals = IBI_rawdata(2:end,2); 
        tEvents = IBI_rawdata(2:end,1);
        N = length(rrIntervals); % number of successive intervals
        rrIntervals = cell2mat (rrIntervals);
        dt = max(rrIntervals)-min(rrIntervals);
        binWidth = 1/128; %standard bin width
        nBins = dt/binWidth;
        [n, xout] = hist(rrIntervals, nBins);

        %% Calculate Time-Domain Parameters
        meanRR = mean(rrIntervals); %s
        SDNN = std(rrIntervals); %s
        RMSSD = sqrt((sum(power(diff(rrIntervals),2)))/(N-1)); %s
        NN50 = sum(abs(diff(rrIntervals)) > .05); %beats
        pNN50 = (NN50/(N-1))*100; % %
        RRT = length(rrIntervals)/max(n); 
            %= N/(number of RR intervals in modal bin)
        TINN = 0;

        %% Set up an array of values
        rightVariables(i+1,:) = [cellstr(rightData(i).name), meanRR, ...
            SDNN, RMSSD, NN50, pNN50, RRT, TINN];
        B = rightVariables;
    end  
end

