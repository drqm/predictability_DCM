# predictability_DCM

In this repository you will find the scripts necessary to reproduce the analyses reported in:

Quiroga-Martinez, D. R., Hansen, N. C., Højlund, A., Pearce, M., Brattico, E., Holmes, E., Friston, K., & Vuust, P. (2021). Musicianship and melodic predictability enhance neural gain in auditory cortex during pitch deviance detection. BioRxiv, 2021.02.11.430838. https://doi.org/10.1101/2021.02.11.430838

These are the scripts and files included in the repository:

* convert_to_spm_m_nm_trials.m: Matlab function to transform Fieldtrip evoked responses into SPM format.
* convert_to_spm_wrapper_DCM_N1_MMN.m: Matlab wrapper to call convert_to_spm_m_nm_trials.m
* lead_field.m: Matalb function to create a head model for each participant.
* inversion.m: Matlab function to run source localization.
* inversion_wrapper_m_nm.m: Matlab wrapper to call lead_field.m and inversion.m
* DCM_invert.m: Matlab function to fit DCM models.
* DCM_inversion_wrapper_m_nm.m: Matlab wrapper to call DCM_invert.

