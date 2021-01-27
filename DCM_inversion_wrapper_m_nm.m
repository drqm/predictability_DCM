clear all
spm('defaults','eeg');
%spm_jobman('initcfg');
cd '/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/predictability_DCM/'
curr_dir = pwd;

%clusterconfig('scheduler','none'); % Run everything without any clusterizing code at all
% clusterconfig('scheduler','local'); % Run everything clusterized but only to the machine you're working on (NB! NOT Hyades01!)
clusterconfig('scheduler','cluster'); % Run everything truly clusterized
%clusterconfig('long_running',2); % for jobs with a duration > 12 hrs
%clusterconfig('long_running',1); % 1 == all.q the job shouldn't take more than 12 hrs

subjects1 = [6,7,9,10,11,13,14,16,18,19,42,45,48,56,60,65,66,67,68,69,12,...
             23,26,29,30,31,32,33,34,35,36,41,43,46,49,51,54,57,58,59];
subjects2 = [1,2,4,5,6,7,8,10,12,13,15,16,17,18,19,20,21,22,23,24,25,26,...
             29,32,33,34,35,36,37,38,39,42,43,44,45,46,47,48,49,50];

conditions = {'HP','LP'};
input = [];
count = 0;

for cc = 1:length(conditions)
    condition = conditions{cc};
    for k = 1:length(subjects2)
        count = count + 1;
        cfg = [];
        cfg.sub_no = subjects2(k);
        load(sprintf([curr_dir '/DCMs/' condition '_DCM_ECD_%02.f_DCM.mat'],cfg.sub_no));
        cfg.DCM = DCM;
        input{count} = cfg;
    end
end
jobid = job2cluster(@DCM_invert, input);

%% Peb wrapper:
% input= [];
% load('GCM_PEB');
% for g = 1:length(GCM_all)
%     cfg = [];
%     DCM = GCM_all{g};
%     DCM.name = [DCM.name(1:end-4),'_PEB.mat'];
%     save(DCM.name,'DCM') 
%     cfg.DCM = DCM;
%     input{g} = cfg;
% end
% jobid = job2cluster(@DCM_invert, input);
