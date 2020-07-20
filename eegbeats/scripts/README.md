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

### Visualizations

>  `runShowRRMeasureBoxplots.m` displays boxplots of RR measures segregated by metadata variable. 

>  `runShowRRMeasureTSNE` displays 2D or 3D TSNE projection plots colored by metadata variable.



### Analysis of variance (ANOVA)

>  `runAnova1.m` runs single factor ANOVA on RRMeasures using a metadata factor variable.

>  `runAnova2.m` runs two-factor ANOVA on RRMeasures using 2 metadata factor variables.

>  `runAnova3.m` runs three-factor ANOVA on RRMeasures using 3 metadata factor variables.

>  `runAnova2bySubject.m` runs two-factor ANOVA on RRMeasures separately for individual subjects.

>  `runCountSignficant.m` creates a table with counts of the number measures for which a factor is significant.


### Informational

> `runCompareFlipped` calculate ekgPeaks forcing flip and noflip for specified list of sessions.
>  This script is used after manual review to re-analyze datasets with suspect peak finding.

> `runCountDatasetsForRRComparison.m` summarizes how many datasets had valid first blocks for EEG-Beats and PNC.

> `runCreateMeta.m`

> `runOutputSummaryCounts.m`

>  `runOutputTxt.m`

>  `runSummarizeManualReview`


### Comparisons

> `runComparePNCPeaks`

>  `runComparePNCRRMeasures.m`

>