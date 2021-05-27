# predictability_DCM

In this repository you will find the scripts necessary to reproduce the analyses reported in:

Quiroga-Martinez, D. R., Hansen, N. C., Højlund, A., Pearce, M., Brattico, E., Holmes, E., Friston, K., & Vuust, P. (2021). Musicianship and melodic predictability enhance neural gain in auditory cortex during pitch deviance detection. BioRxiv, 2021.02.11.430838. https://doi.org/10.1101/2021.02.11.430838

The results of the study are obtained with the PEB_MMN_entropy.m and plot_pars_and_probs.R scripts. This requires downloading the data stored in the OSF repository:
https://doi.org/10.17605/osf.io/bdr73

These are the scripts and files included in the repository:

* convert_to_spm_m_nm_trials.m: Matlab function to transform Fieldtrip evoked responses into SPM format.
* convert_to_spm_wrapper_DCM_N1_MMN.m: Matlab wrapper to call convert_to_spm_m_nm_trials.m
* lead_field.m: Matalb function to create a head model for each participant.
* inversion.m: Matlab function to run source localization.
* inversion_wrapper_m_nm.m: Matlab wrapper to call lead_field.m and inversion.m
* DCM_invert.m: Matlab function to fit DCM models.
* DCM_inversion_wrapper_m_nm.m: Matlab wrapper to call DCM_invert.
* PEB_MMN_entropy.m: Matlab script to run the group-level analyses of DCM models.
* plot_sources.m: Matlab script to plot the output of source statistics.
* plot_surfaces.m: Matlab script to plot the DCM network in a glass-brain surface. 
* plot_pars_and_probs.R: R script to plot the output of group-level analyses.
* analyze_demographics.R: R script to analyze demographic info.
* Left_edges.edge and Right_edges.edge: text files including connection matrices to plot the edges of the DCM network.
* Left_nodes.node and Right_nodes.node: text files including coordinates of the nodes in the DCM network for plotting.
* participants_info_anonymized_m_nm.csv: csv file with anonymous participant information.
* demographics_table.csv: csv file with summary demographics.
* results/: folder with the output figures.
