function out = convert_to_spm_m_nm_trials(input)
spm('defaults','eeg')
out = [];
sub_no = input.sub_no;
N1_conds = input.N1_conds;
MMN_conds = input.MMN_conds;
N1_names = input.N1_names;
MMN_names = input.MMN_names;
cond_names = [N1_conds,MMN_conds];
out_names = [N1_names,MMN_names];
tl_file_N1 = input.tl_file_N1;
tl_file_MMN = input.tl_file_MMN;
struc_name_N1 = input.struc_name_N1;
struc_name_MMN = input.struc_name_MMN;
raw_dir = input.raw_dir;
prov_dir = input.prov_dir;
out_dir = input.out_dir;
ft_dir_N1 = input.ft_dir_N1;
ft_dir_MMN = input.ft_dir_MMN;

if ~exist(prov_dir,'dir')
    mkdir(prov_dir)
end
if ~exist(out_dir,'dir')
    mkdir(out_dir)
end

raw_fname = input.raw_filename;
S = []; % Clear the SPM configuration and data
S.dataset = [raw_dir raw_fname '_ica-vis-raw.fif'];
S.outfile = [prov_dir sprintf('%02.f', sub_no), '_spmeeg_MMN'];
S.continuous = 1; % Configure reading continuous data
spm_eeg_convert(S);
load([prov_dir sprintf('%02.f', sub_no), '_spmeeg_MMN'])
raw = D;

data = [];
expression = 'ft_appendtimelock([]';

if ~isempty(N1_conds)
    data.N1 = load([ft_dir_N1,sprintf('%02.f_',sub_no),tl_file_N1]);
    for nn = 1:length(N1_conds)
        expression = [expression,',','data.N1.', struc_name_N1, '.', N1_conds{nn}];
    end
end
if ~isempty(MMN_conds)
    data.MMN = load([ft_dir_MMN,sprintf('%02.f_',sub_no),tl_file_MMN]);
    for mm = 1:length(MMN_conds)
        expression = [expression,',', 'data.MMN.', struc_name_MMN, '.', MMN_conds{mm}];
    end
end
expression = [expression,')'];
app_data = eval(expression);

cfg = [];
cfg.channel = 'MEG*1';
app_data = ft_selectdata(cfg,app_data);
spm_eeg_ft2spm(app_data, [out_dir,sprintf('%02.f', sub_no)]);
load([out_dir,sprintf('%02.f', sub_no)])

for cc = 1:length(cond_names)
D.trials(cc).label = cond_names{cc};
end

D.condlist = out_names;

for k = 1:length(D.channels)
    for l = 1:length(raw.channels)
        new_label{k,1} = D.channels(k).label;
        if strcmp(D.channels(k).label,raw.channels(l).label)
            D.channels(k).bad = raw.channels(l).bad;
            D.channels(k).type = raw.channels(l).type;
            D.channels(k).X_plot2D = raw.channels(l).X_plot2D;
            D.channels(k).Y_plot2D = raw.channels(l).Y_plot2D;
            D.channels(k).units = raw.channels(l).units;
        end
    end
end
ind = ismember(raw.sensors.meg.label, new_label);
sensors = raw.sensors;
sensors.meg.label = new_label;
sensors.meg.chanori = sensors.meg.chanori(ind,:);
sensors.meg.chanpos = sensors.meg.chanpos(ind,:);
sensors.meg.chantype = sensors.meg.chantype(ind,1);
sensors.meg.chanunit = sensors.meg.chanunit(ind,1);
sensors.meg.tra = sensors.meg.tra(ind,:);

D.sensors = sensors;
D.fiducials = raw.fiducials;

save([out_dir, sprintf('%02.f', sub_no) '_DCM'],'D','-v7.3')


delete([prov_dir sprintf('%02.f', sub_no), '_spmeeg_MMN.mat'])
delete([prov_dir sprintf('%02.f', sub_no), '_spmeeg_MMN.dat'])