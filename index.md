## Introduction to the EEG-Beats

EEG-Beats is a MATLAB toolbox that extracts heartbeat peaks and interbeat interval measures from a single channel of EEG that has been recorded by placing an EEG sensor on the upper portion of the chest. Scripts provide automated processing for all .set files in a directory tree. An EEGLAB plugin is also available. EEGLAB is required for EEG-Beats even if not run as a plugin.

Table of Contents:
* [Introduction (requiremen,citing,installation)](#Introduction-to-the-EEG-Beats)
* [Running as an EEGLAB plug-in](#EEG-Beats-as-a-EEGLAB-plugin)
* [Running as a script]()
* [Algorithms (steps, meaning of parameters for each step)](#EEG-Beats-parameters-and-their-default-settings)


### Requirements
The EEG-Beats uses MATLAB and EEGLAB. EEGLAB is available from http://scn.ucsd.edu/eeglab. EEG-Beats assumes that the EEG data is provided as a .set file.

### Citing EEG-Beats

EEG-Beats is freely available under the GNU General Public License. Please cite the following publication if using:
> Thanapaisal S, Mosher S, Trejo B, and Robbins KA (2020) <br/>												
> EEG-Beats: Automated analysis of heart rate variability (HVR) from EEG-EKG  
> https://biorxiv.org/cgi/content/short/2020.07.21.211862v1


### Installation
EEG-Beats can be run in two ways --- as a standalone toolbox or as an EEGLAB plugin. To run in standalone mode, simply download the EEG-Beats
repository from https://github.com/VisLab/EEG-Beats. Unzip if necessary and then add eegbeats directory and all of its subdirectories to your
MATLAB path.  

___

### EEG-Beats as a EEGLAB plugin
You can install EEG-Beats as an EEGLAB plugin by installing through the EEGLAB. Alternatively you can also directly unzip eegbeats.1.1.2.zip in the EEGLAB plugins 	directory.
1. Install the plugin through the EEGLAB Extension Manager (File -> Manage EEGLAB Extensions)
2. Load an EEG .set file into EEGLAB
3. Run EEG-Beats through the EEGLAB Tools menu.

#### Video Tutorial using EEG-Beats as a EEGLAB plugin
[![Image](https://raw.githubusercontent.com/VisLab/EEG-Beats/tree/gh-pages/YoutubeThumbnail3.png)](https://youtu.be/rQLI58qfqiU)
[![Image](https://raw.githubusercontent.com/nthanapaisal/EEG-Beats/gh-pages/Images/YoutubeThumbnail3.png)](https://youtu.be/rQLI58qfqiU)


___

###  EEG-Beats Defaults:

Output Directories:

* **fileDir** is a string of base name (including path) of the file for saving. The default value is an empty string and EEG-Beats will not save to file.
	
* **figureDir** is a string of base name (including path) to save the plot as a .fig and a .png file. The default value is an empty string and EEG-Beats will not save to file.

Finding Heartbeats parameters:

* **ekgChannelLabel** is a string for labeling the EEG channel containing the EKG signal.<br/>
> **Example**: `'EKG'`<br/>
> This set 'EKG' as a label.

* **filterHz** is a 2-element vector giving the frequency limits of the band-pass filter applied to the raw signal before processing.<br/>
> **Example:** `[3,20]`<br/>
> This specifies that the signal is band-pass filtered to be between 3 Hz and 20 Hz.

* **srate** is a positive integer for the frequency to resample raw ekg signal at before filtering.<br/> 
> **Example:** `128`<br/>
> This specifies that the frequency is 128 Hz.
	
* **truncateThreshold** is a positive number of robust stds away from median to truncate ekg before detecting heartbeats.<br/>
> **Example:** `15`<br/>
> This specifies the threshold to be 15 stds away from the median.

* **rrMaxMs** is a positive number giving the maximum number of milliseconds between peaks for valid RRs.<br/>
> **Example:** `1500`<br/>
> This specifies the maximum between peaks for RRs to be 1500 ms.

* **rrMinMs** is a positive number giving the minimum number of milliseconds between peaks for valid RRs.<br/>
> **Example:** `500`<br/>
> This specifies the minimum between peaks for RRs to be 500 ms.

* **threshold** is a positive number for the minimum heartbeat amplitude in units of robust stds away from median signal.<br/>
> **Example:** `1.5`<br/>
> This sets the minimum heartbeat amplitude to be 1.5

* **qrsDurationMs** is a positive number for the maximum width of a heartbeat peak in milliseconds.<br/>
> **Example:** `200`<br/>
> This specifies the maximum width of a heartbeat peak to be 200 ms.
	
* **flipIntervalSeconds** is a postive number for the length of subintervals in partition of signal to determine dominant heartbeat direction.<br/>
> **Example:** `2`<br/>
> This sets length of subintervals to be 2.

* **flipDirection** is an interger determining whether we want to flip the direction of the signal. If 0, use consensus algorithm. If 1 then flip. If -1, do not filp.<br/>
> **Example:** `0`<br/>
> This specifies EEG-Beats to use consensus algorithm to dethermine the flip direction of the signal. 

* **consensusIntervals** is a postive number for the intervals to partition the signal to determine initial fenceposts.<br/>
> **Example:** `31`<br/>
> This sets number of intervals to be 31 intervals.
	
* **maxPeakAmpRatio** is a positive number of the outlier peaks whose absolute amplitude is greater than abs(maxPeakAmpRatio*median peak) are considered high amplitude.<br/>
> **Example:** `2`<br/>
> This sets the maximum outlier peaks to be 2.

* **minPeakAmpRatio** is a number of outlier peaks whose absolute amplitude is less than abs(minPeakAmpRatio*median peak) are considered low amp peaks.<br/>
> **Example:** `0.5`<br/>
> This sets the minimum outlier peaks to be 0.5.

* **maxWhisker** is a number of maximum whisker length for outlier peaks in units of iqr of peak distribution.<br/>
> **Example:** `1.5`<br/>
> This specifies the maximum whisker to be 1.5

RR measures parameters:
* **verbose:** is a logical input to determine if EEG-Beats should output intermediate algorithm information. If true, output intermediate algorithm information.<br/>
> **Example:** `1`<br/>
> This specifies the EEG-Beats to output intermediate algorithm information.

* **doRRMeasures:** is a logical input to determine if the user wants to calculate RR measures.<br/>
> **Example:** `1`<br/>
> This is true and the EEG-Beats will calculate RR measures.

* **rrsAroundOutlierAmpPeaks:** is a postive number, if > 0,exclude specified number of RRs on either side of peaks that are too high or too low in RR measure calculation.<br/>
>  **Example:** `1`<br/>
> This...

* **rrOutlierNeighborhood:** is a positive number, If > 0, total number of RR neighbors before and after (balanced if possible) to use to calculate neighborhood average.<br/>
> **Example:** `5`<br/>
> This...

* **rrPercentToBeOutlier:** is positive number for the percent above and below neighborhood average to designate RR value as outlier (only used if RROutlierNeighborhood > 0).<br/>
> **Example:** `20`<br/>
> This...

* **rrBlockMinutes:** is a positve number for the block size in minutes for computing RR measures.<br/>
> **Example:** `5`<br/>
> This indicates that the block size is 5.

* **rrBlockStepMinutes:** is a positve number for the minutes to slide window for computing RR measures.<br/>
> **Example:** `0.5`<br/>
> This...
		
* **detrendOrder:** is a positve number for an order of polynomial for detrending RRs or 0 if no detrend prior to computing the measures.<br/>
> **Example:** `3`<br/>
> This...
		
* **removeOutOfRangeRRs:** is a logical input. If true, remove RRs that are less than rrMinMs or greater than rrMaxMs when calculated RR measures.<br/>
> **Example:** `1`<br/>
> This...

* **spectrumType:** is a string input for spectrum type. Type of spectrum: 'lomb', 'ar', 'fft'.<br/> 
> **Example:** `'lomb'`<br/>
> This sets the spectrum type to be 'lomb'.

* **arMaxModelOrder:** is a postive number for the maximum order of the AR model fit to determine AR spectrum.<br/> 	
> **Example:** `25`<br/>
> This...

* **resampleHz:** is a postive number for the resampling frequency for FFT representation of spectrum.<br/> 
> **Example:** `4`<br/>
> This...

* **freqCutoff:** is a postive nunber for the upper frequency bound in Hz for computing total power in IBI spectrum.<br/> 
> **Example:** `0.4`<br/>
> This...

* **VLFRange:** is a postive 2-element vector giving the upper frequency bound in Hz for computing VLF (very low frequency) power in RR spectrum.<br/> 
> **Example:** `[0.0033,0.04]`<br/>
> This...

* **LFRange:** is a postive 2-element vector giving the range in Hz for computing LF (low frequency) power in RR spectrum.<br/>
> **Example:** `[0.04,0.15]`<br/>
> This...

* **HFRange:** is a postive 2-element vector giving the range in Hz for computing HF (high frequency) power in RR spectrum.<br/>
> **Example:** `[0.15,0.04]`<br/>
> This...

Plot Options:
* **doPlot:** is a logical input specifies if the user want to produce a plot of EKG signal with heartbeats marked.<br/>
> **Example:** `1`<br/>
> This is true for EEG-BEats and it will produce the plot.

* **figureClip:** is a postive number if the user wants the plots to be clipped. If infinity, plots are clipped at figureClip*iqr outside iqr.<br/>
> **Example:** `3`<br/>
> This...

* **figureVisibility:**  is a string input to determine whether to shows figures, otherwise creates but does not display (for non-interactive mode).<br/>
> **Example:** `'on'`<br/>
> This sets it to true and EEG-Beats will show the figures.

* **figureClose:**  is a logical input to close the figure after displaying/saving it.
> **Example:** `0`<br/>
> This does not close the figure after displaying/saving it.

