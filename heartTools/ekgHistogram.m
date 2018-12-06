%% Make a histogram of the ekg indicator
% Used to determine if the data is reasonable.

%% Load the data
ibiSummaryPath = 'E:\sabrina\Documents\EKG\Anova\IndicatorStruct.mat';
test = load(ibiSummaryPath);
ibiStatsSummary = test.ibiStatsSummary;

%% Get the mean data
meanIbi = cell2mat({ibiStatsSummary.mean});
figure('Name', 'IBI mean');
hist(meanIbi, sqrt(length(meanIbi)));
xlabel('IBI mean');
ylabel('count');

%% Some histfit
figure('Name', 'IBI mean fit-lognormal');
h = histfit(meanIbi, 25, 'lognormal');
xlabel('IBI mean');
ylabel('count');

%% Fitdist
pd = fitdist(meanIbi(:), 'lognormal');