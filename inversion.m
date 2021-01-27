%-----------------------------------------------------------------------
% Job saved on 28-Apr-2020 21:02:47 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
% cfg_mindlab MindLab - Unknown
%-----------------------------------------------------------------------
function out = inversion(input)
out = [];
spm('defaults','eeg');
%spm_jobman('initcfg');
matlabbatch{1}.spm.meeg.source.invert.D = {input.meg_file};
matlabbatch{1}.spm.meeg.source.invert.val = input.val;
matlabbatch{1}.spm.meeg.source.invert.whatconditions.all = 1;
matlabbatch{1}.spm.meeg.source.invert.isstandard.standard = 1;
matlabbatch{1}.spm.meeg.source.invert.modality = {'All'};
matlabbatch{2}.spm.meeg.source.results.D(1) = cfg_dep('Source inversion: M/EEG dataset(s) after imaging source reconstruction', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','D'));
matlabbatch{2}.spm.meeg.source.results.val = input.val;
matlabbatch{2}.spm.meeg.source.results.woi = input.latency;
matlabbatch{2}.spm.meeg.source.results.foi = [0 0];
matlabbatch{2}.spm.meeg.source.results.ctype = 'evoked';
matlabbatch{2}.spm.meeg.source.results.space = 1;
matlabbatch{2}.spm.meeg.source.results.format = 'image';
matlabbatch{2}.spm.meeg.source.results.smoothing = input.smoothing;
spm_jobman('run',matlabbatch);
end