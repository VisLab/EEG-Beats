# Batch scripts for EEG-Beats

EEG-Beats supports peak-finding, computation of interbeat interval measures, and analysis
in batch mode. All of these scripts are in the `scripts` subdirectory.

### Computation of peak locations and RR measures

> `runGetHeartBeats.m` calls `eeg_beats` on a directory tree containing EEG files and
>  produces an `ekgPeaks` data structure containing the peak information for all of these files.
>  The script also outputs figure files for all of the peak and RR interval visualizations.

>  `runGetRRMeasures` calls `eeg_ekgstats` on the `ekgPeaks` data structure and produces an
>  `rrInfo` structure containing all of the RR measure information for the study.  

> `runProcessEkg` calls `pop_eegbeats` on a directory tree containing EEG files and
> produces both a `ekgPeaks` data structure and `rrInfo` structure for the study in one step.    

