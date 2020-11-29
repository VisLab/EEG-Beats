Download WFDB Matlab toolbox to use their functions (https://archive.physionet.org/physiotools/matlab/wfdb-app-matlab/)

mit directory:
	contains MITDB

set directory:
	contains *.set from MITDB
	
compareInfo.mat:
	contains information after compared the result of eegbeats and mit annotations for those datasets
___________________________________________________________________________________________________
convertDat2Set.m:
	This script will convert .dat file into .set. 
	
	Notes:
	Make sure to specify the input directory which contains *.dat using this variable (data).
___________________________________________________________________________________________________
comparePeakTm.m:
	This script will run eegbeats and compare the peaks with mit annotations for each dataset.
	
	Notes:
	Make sure to specify the input directories using these variable (setDir and mitDir). This script will create an output file(compareInfo.mat).
___________________________________________________________________________________________________


