clear all
%spm('defaults','eeg');
%spm_jobman('initcfg');
cd '/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/predictability_DCM'
curr_dir = pwd;
% clusterconfig('scheduler','none'); % Run everything without any clusterizing code at all
% clusterconfig('scheduler','local'); % Run everything clusterized but only to the machine you're working on (NB! NOT Hyades01!)
% clusterconfig('scheduler','cluster'); % Run everything truly clusterized
clusterconfig('long_running',1); % for jobs with a duration > 1 hr && < 12 hrs
% clusterconfig('long_running',2); % for jobs with a duration > 12 hrs
% clusterconfig('long_running',1); % 1 == all.q the job shouldn't take more than 12 hrs
% 
subjects1 = [6,7,9,10,11,13,14,16,18,19,42,45,48,56,60,65,66,67,68,69,12,23,26,29,30,31,32,33,34,35,36,41,43,46,49,51,54,57,58,59];
subjects2 = [1,2,4,5,6,7,8,10,12,13,15,16,17,18,19,20,21,22,23,24,25,26,29,32,33,34,35,36,37,38,39,42,43,44,45,46,47,48,49,50];
% subjects1 = 6;
% subjects2 = 1;
% conditions = {'entropy_p','entropy_i','entropy_t','entropy_s','HEpMMN','HEiMMN','HEtMMN','HEsMMN','LEpMMN','LEiMMN','LEtMMN','LEsMMN'};
% latencies = {[150 200],[150 200],[150 200],[150 200],[170 210],[110 150],[110 150],[270 310],[170 210],[110 150],[110 150],[270 310]};

input = [];
count = 0;

for k = 5:length(subjects1)
    count = count + 1;
    cfg = [];
    cfg.latency = [70, 300];
    cfg.subject = subjects1(k);
    cfg.sub_no = subjects2(k);
    cfg.mri_dir = sprintf('/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/data2018June5/00%02d/', cfg.subject);
    cfg.meg_file = sprintf([curr_dir '/data/%02.f_DCM.mat'],cfg.sub_no);
    cfg.val = 1;
    cfg.mesh_res = 3;
    cfg.smoothing = 32;
    %lead_field(cfg)
    %inversion(cfg)
    input{count} = cfg;
end

%jobid = job2cluster(@lead_field, input);
jobid = job2cluster(@inversion, input);
