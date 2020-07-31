# EEG-Beats Develop branch
Matlab toolbox to analyze heart rate variability (HRV) in conjunction with EEG

This MATLAB toolbox extracts heartbeat peaks and interbeat interval measures
from a single channel of EEG that has been recorded by placing an EEG
sensor on the upper portion of the chest. Scripts provide automated
processing for all `.set` files in a directory tree. An EEGLAB plugin is
under development.  

### Citing EEG-Beats
EEG-Beats is freely available under the GNU General Public License. 
Please cite the following publication if using:  
> Thanapaisal S, Mosher S, Trejo B and Robbins KA (2020)  
> EEG-Beats: Automated analysis of heart rate variability (HVR) from EEG-EKG  
> [https://biorxiv.org/cgi/content/short/2020.07.21.211862v1](https://biorxiv.org/cgi/content/short/2020.07.21.211862v1)

### Running EEG-Beats

Download the EEG-Beats repository and add the `eegbeats` directory and all of
its subdirectories to your MATLAB path. EEG-Beats is designed to be run in
two stages: extract the heartbeats from the EEG and compute RR measures from the
heartbeats.  

### Top-level functions
EEG-Beats has four top level functions:
1. `eeg_beats` takes an EEG `.set` file and produces a structure containing the heartbeat peaks.
2. `eeg_ekgstats` takes the peak structure produced by `eeg_beats` and produces an interbeat interval measure structure.
3. `eegplugin_eegbeats` provides the EEGLAB plugin infrastructure and is not meant to be called directly by users.
4. `pop_eegbeats` performs the entire process in one step. The EEGLAB plugin calls this function, but
it also can be called from user scripts or from the command line.

### Running EEG-Beats from scripts
The `scripts` subdirectory has an extensive collection of scripts that are designed to call EEG-Beats
in batch mode on an entire study. A detailed list of scripts appears in the `README.md` file located
in this subdirectory.  

### Setting EEG-Beats parameters
All parameters in EEG-Beats are settable.  EEG-Beats uses a `params` structure to hold the 
parameters. The following functions are useful for listing the values of the parameters and setting them.  

**Example** The following command on the command line lists all EEG-Beat parameters and
their default settings.

    outputBeatDefaults(); 


**Example** The following example creates an empty `params` structure, sets the `rrMinMs` parameter to 400 ms
and, then fills the structure with the default values for all other parameters.

    params = struct();
    params.rrMinMs = 400;
    params = checkBeatDefaults(params, params, getBeatDefaults());

### Releases

Version 1.0 Released 7/28/2020  
* Initial release of EEG-Beats sans EEGLAB plugin gui   