# EEG-Beats
Matlab toolbox to analyze heart rate variability (HRV) in conjunction with EEG

This MATLAB toolbox extracts heartbeat peaks and interbeat interval measures
from a single channel of EEG that has been recorded by placing an EEG
sensor on the upper portion of the chest. Scripts provide automated
processing for all `.set` files in a directory tree. An EEGLAB plugin is
under development.  

### Citing EEG-Beats
EEG-Beats is freely available under the GNU General Public License. 
Please cite the following publication if using:  
> Thanapisal S, Mosher S, Trejo B and Robbins KA (2020)  
> EEG-Beats: Automated analysis of heart rate variability (HVR) from EEG-EKG

### Running EEG-Beats

Download the EEG-Beats repository and add the eegbeats directory and all of
its subdirectories to your MATLAB path. EEG-Beats is designed to be run in
two stages: extract the heartbeats from the EEG and compute RR measures from the
heartbeats.  

### Top-level functions
EEG-Beats has four top level functions:
1. `eeg_beats` takes an EEG .set file and produces a structure containing the heartbeat peaks.
2. `eeg_ekgstats` takes the peak structure produced by `eeg_beats` and produces an interbeat interval measure structure.
3. `eegplugin_eegbeats` provides the EEGLAB plugin infrastructure and is not meant to be called directly by users.
4. `pop_eegbeats` performs the entire process in one step. The EEGLAB plugin calls this function, but it is also called from user scripts.


