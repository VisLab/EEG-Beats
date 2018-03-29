function [ ibi, brMatched, brUnmatched, ptUnmatched ] = findConsecutiveRR( brPeaks, ptPeaks )
%% Determine which of the refined R peaks are consecutive 
%   findConsecutiveBeats finds with R peaks found are consecutive and tests
%   how many of our peaks matched the PanTompkins algorithm's peaks. 
%
% Parameters:
%   myPeaks     The output of the Beat Refinment Algo which contains the indices of R
%               peaks in sample numbers.
%   ptPeaks     The output of the Pan-Tompkins algorithm which contains the
%               indices of R peaks in sample numbers.
%   ibi         (output) A two column array containing the
%               inner-beat-interval values in samples and seconds, 
%               respectively .
%   brMatched   (output) An array of indicies specifying which peaks from the
%               Beat Refinement algoritm were matched with the peaks from the 
%               Pan-Tompkins algorithm.  
%   brUnmatched (output) An array of indices containing all R peaks from
%               the Beat Refinment algorithm that were not found in the 
%               Pan-Tompkins algorithm.
%   ptUnmatched (output) An array of indices containing all R peaks from
%               the Pan-Tompkins algorithm that were not found in the 
%               Beat Refinmentt algorithm. 
%%

%% Initialize variables for matching

brMatched = -ones(length(brPeaks), 1);
myP = 1;        % Position of my next peak to be matched
theirP = 1;     % Position of their next peak to be matched
margin = 5;

%% Match common peaks
while myP <= length(brPeaks) && theirP <= length(ptPeaks)
   if brPeaks(myP) < (ptPeaks(theirP) - margin)
      %Our sample is too far to the left, move it to the right. 
       myP  = myP + 1;
   elseif ptPeaks(theirP) - margin <= brPeaks(myP) && ...
           brPeaks(myP) <= ptPeaks(theirP) + margin 
       
       %Your peak is within the margin of theirs, add it to myMatch then
       %move right. 
       brMatched(myP) = theirP;
       myP = myP + 1;
       theirP = theirP + 1;
   else
       % Our sample is too far to the right, move theirs right. 
       theirP = theirP + 1;
   end
end

%% Which peaks in theirPeaks are not matched
allIndices = (1:length(ptPeaks))';
ptUnmatched = setdiff(allIndices, brMatched);

%% Which peaks in yours that were not matched
 brUnmatched = find(brMatched == -1);
 
 % Find where difference is only 1 (beats are consecutive)
 diffMatch=diff(brMatched);
 diffMask = diffMatch == 1; %Logical array if cons. beats are found
 diffIndices = 1:length(brPeaks); 
 diffIndices = diffIndices(diffMask); % keep index of cons. peaks

 IBI = brPeaks(diffIndices+1) - brPeaks(diffIndices); % IBI in sample numbers
 IBIsec = IBI/200; %convert them to seconds
 
 %% Add the headers and concatinate
ibi = vertcat(IBI', IBIsec');
end

