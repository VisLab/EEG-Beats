function [ibi, tooLarge, tooSmall] = generateIBI(peaksTm, maxDist, minDist)
%% Get the inter-beat intervals of the peaks with errors for being too far
%  apart or too close together.
% Input: 
%   peaksTm     the time of the peaks to get the ibi from
%   maxDist     the maximum allowed distance between peaks
%   minDist     the minimum allowed distance between peaks
% Returns:
%   the ibi
%   a list of invalid peaks that are too far apart
%       (the first peak in that pair)
%   a list of invalid peaks that are too close together
%       (the first peak in that pair)
%%
    % Initialize the ibi
    ibi = zeros(length(peaksTm)-1, 2);
    
    % Set the times of the peaks
    ibi(:,1) = peaksTm(1:end-1);
    
    % get the times
    ibi_times = peaksTm(2:end) - peaksTm(1:end-1);
    
    %Set the ibi
    ibi(:,2) = ibi_times;
    
    % clear rows where ibi > threshold or = 0
    tooLarge = ibi(ibi(:,2) > maxDist, :);
    tooLarge = tooLarge(:,1);
    tooSmall = ibi(ibi(:,2) < minDist, :);
    tooSmall = tooSmall(:,1);
    ibi(ibi(:,2) > maxDist, :) = [];
    ibi(ibi(:,2) < minDist, :) = [];
    
end

