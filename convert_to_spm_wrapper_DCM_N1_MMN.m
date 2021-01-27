clear all

cd '/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/predictability_DCM'
curr_dir = pwd;
% clusterconfig('scheduler','none'); % Run everything without any clusterizing code at all
% clusterconfig('scheduler','local'); % Run everything clusterized but only to the machine you're working on (NB! NOT Hyades01!)
clusterconfig('scheduler','cluster'); % Run everything truly clusterized
% clusterconfig('long_running',1); % for jobs with a duration > 1 hr && < 12 hrs
% clusterconfig('long_running',2); % for jobs with a duration > 12 hrs
% clusterconfig('long_running',1); % 1 == all.q the job shouldn't take more than 12 hrs

%addpath /users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scripts/Pipeline/source_analysis        
subject_list = {'0001_FQ2','0002_EWL','0003_HDT','0004_FIX','0005_HJC','0006_KS2','0007_9BH',...
                '0008_TBT','0009_IIK','0010_PUY','0011_0W8','0012_GLD','0013_RFL','0014_V3N',...
                '0015_C8V','0016_OCA','0017_KUS','0018_TJ2','0019_OBV','0020_HUL','0021_SP4',....
                '0022_RRL','0023_LYL','0024_9T5','0025_MCY','0026_GRL','0027_JII','0028_A6D',...
                '0029_L8P','0030_LVN','0031_RHO','0032_CYT','0033_B7Z','0034_N5S','0035_65S',....
                '0036_MA4','0037_DX3','0038_YOW','0039_VI3','0040_5RD','0041_XPU','0042_H3A',...
                '0043_GQS','0044_FKU','0045_ZNS','0046_OWE','OO47_5OT','0048_BB8','0049_MPH','0050_ZVN',...
                '0051_28G','0052_T8Y','0053_VCF','0054_YV7','0055_WC6','0056_PZB','0057_EZN',...
                '0058_34E','0059_MUV','0060_KL1','0061_MXM','0062_XFK','0063_UVT','0064_OCI',...
                '0065_8NI','0066_H4R','0067_ATM','0068_BJ7','0069_BCV'};

% exp.m = [12,23:37,40,41,43,46,49,51,54,57,58,59]; % musicians Exclude 61 and 62 too noisy
% exp.nm = [6,7,8,9,10,11,13:20,42,45,48,56,60,65,66,67,68,69];


subject_codes = [6,7,9:14,16,18,19,23,25,26,27,29:37,41,42,43,45,46,48,49,51,54,56,57:60,65:69];
exp.m = [12,23:37,40,41,43,46,49,51,54,57,58,59]; % musicians Exclude 61 and 62 too noisy
exp.nm = [6,7,8,9,10,11,13:20,42,45,48,56,60,65,66,67,68,69];

out_code.nm = 1:24;
out_code.m = 25:50;

out_code.nm = out_code.nm(ismember(exp.nm,subject_codes));
exp.nm = exp.nm(ismember(exp.nm,subject_codes));
out_code.m = out_code.m(ismember(exp.m,subject_codes));
exp.m = exp.m(ismember(exp.m,subject_codes));

subject_codes = [exp.nm(1:end),exp.m];
%subject_codes = 6;
subject_numbers = [out_code.nm(1:end),out_code.m];
%subject_numbers = 1;
input = [];
cfg = [];
% cfg.conditions = {'HEpMMN','HEiMMN','HEtMMN','HEsMMN','LEpMMN','LEiMMN','LEtMMN','LEsMMN','entropy_p','entropy_i','entropy_t','entropy_s'};
% cfg.out_names = {'HEpMMN','HEiMMN','HEtMMN','HEsMMN','LEpMMN','LEiMMN','LEtMMN','LEsMMN','entropy_p','entropy_i','entropy_t','entropy_s'};

cfg.N1_conds = [];%{'i1','i5'}; %{'q1','q10'};
cfg.MMN_conds = {'HEps','HEpd','LEps','LEpd'};
cfg.N1_names = [];%{'i1','i5'};%{'q1','q10'};
cfg.MMN_names = {'HEps','HEpd','LEps','LEpd'};
cfg.ft_dir_N1 = '/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/IC_analyses_share/timelocked_data/data/';
cfg.ft_dir_MMN = '/users/david/Desktop/MINDLAB2016_MEG-DichoticMMN/scratch/entropy_share_m_nm/timelocked_data/data/';
cfg.tl_file_N1 = 'timelock_both_plus_scaled_interval_IC_int_control';%'timelock_ltm_scaled_IC_10cat';
cfg.tl_file_MMN = 'timelocked';
cfg.struc_name_N1 = 'timelock_IC';
cfg.struc_name_MMN = 'timelockr';
cfg.prov_dir = [curr_dir '/data/'];
cfg.out_dir = [curr_dir '/data/'];
cfg.raw_filename ='dichotic1_raw_tsss';

for k = 1:length(subject_codes)
    cfg.subject = subject_list{subject_codes(k)};
    cfg.raw_dir = ['/projects/MINDLAB2016_MEG-DichoticMMN/scratch/ICA_eog_ecg_same_init/',cfg.subject,'/manual/'];
    cfg.sub_no = subject_numbers(k);
    input{k} = cfg;
end

jobid = job2cluster(@convert_to_spm_m_nm_trials, input);
