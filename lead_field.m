%-----------------------------------------------------------------------
% Job saved on 24-Jan-2018 18:41:50 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6906)
% cfg_basicio BasicIO - Unknown
% cfg_mindlab MindLab - Unknown
%-----------------------------------------------------------------------

function out = lead_field(input)
spm('defaults','eeg');
%spm_jobman('initcfg');
out = [];
mri_dir = input.mri_dir;
meg_file = input.meg_file;
mri_folder_content = dir(mri_dir);
mri_folder = mri_folder_content(end).name;
matlabbatch{1}.spm.meeg.source.headmodel.D = {meg_file};
matlabbatch{1}.spm.meeg.source.headmodel.val = input.val;
matlabbatch{1}.spm.meeg.source.headmodel.comment = '';
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshes.mri = {sprintf([mri_dir '%s/MR/T1UNIMOCO_LOOKUP_T1/NATSPACE/0001.nii'],mri_folder)};
matlabbatch{1}.spm.meeg.source.headmodel.meshing.meshres = input.mesh_res;
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).fidname = 'Nasion';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(1).specification.select = 'nas';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).fidname = 'LPA';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(2).specification.select = 'lpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).fidname = 'RPA';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.fiducial(3).specification.select = 'rpa';
matlabbatch{1}.spm.meeg.source.headmodel.coregistration.coregspecify.useheadshape = 1;
matlabbatch{1}.spm.meeg.source.headmodel.forward.eeg = 'EEG BEM';
matlabbatch{1}.spm.meeg.source.headmodel.forward.meg = 'Single Shell';
spm_jobman('run',matlabbatch);
end