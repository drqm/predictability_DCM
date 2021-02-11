function PEB_MMN_entropy
spm('defaults','eeg')
%% First load the model architectures to compare:
% If the script is not in the porject directory, change working dir as desired:
% project_dir = 'XXX';
% cd(project_dir)

out_dir = 'results/data/';
fig_dir = 'results/figures/';

if ~exist(out_dir,'dir')
    mkdir(out_dir)
end
if ~exist(fig_dir,'dir')
    mkdir(fig_dir)
end

%Load DCM solutions
N1 = 20;
N2 = 20;
exclude = [28,30,40];
GCM = struct2table(dir('DCMs/*P_DCM_ECD*.mat'));

if ~isempty(exclude)
    expression = 'find(contains(GCM.name, num2str(exclude(1)))';
    if length(exclude) > 1
        for e = 2:length(exclude)
            expression = [expression,'|contains(GCM.name, num2str(exclude(' num2str(e) ')))'];
        end
    end
    expression = [expression,')'];
    GCM(eval(expression),:) = [];
end

GCM = cellstr([cell2mat(GCM.folder),repmat('/',size(GCM,1),1),cell2mat(GCM.name)]);
GCM = spm_dcm_load(GCM);

%% Make models to compare

template = GCM{1,1};

DCM = [];
DCM.A = template.A;
DCM.B = template.B;
DCM.C = template.C;
DCM.options = template.options;

connections = {'I','O','F','B'};
idx = {[1,7,13,19],[3,9],[11,17],[15,23,25]};
templates = []; names = [];families = [];

DCM2 = DCM;
DCM2.B{1}(:,:) = 0;
templates{1,end+1} = DCM2; names{1,end+1} = 'nullMMN';
families(:,end+1) = ones(length(connections),1)*1;

for c1 = 0:1
    for c2 = 0:1
        for c3 = 0:1
            for c4 = 0:1
                if sum([c1,c2,c3,c4])>0
                    DCM2 = templates{1,end};
                    DCM2.B{1}(idx{1}) = c1*1;
                    DCM2.B{1}(idx{2}) = c2*1;
                    DCM2.B{1}(idx{3}) = c3*1;
                    DCM2.B{1}(idx{4}) = c4*1;
                    nameidx = unique((1:4).*[c1,c2,c3,c4]);
                    curname = [connections{nameidx(nameidx>0)}];
                    templates{1,end+1} = DCM2;
                    names{1,end+1} = curname;
                    families(:,end+1) = [c1,c2,c3,c4]+1;
                end
            end
        end
    end
end

%% Make design matrix

cent = -1; %mean centered? -1 = yes, 0 = no
X = [ones(2*(N1+N2),1),[ones(N1+N2,1);zeros(N1+N2,1)+cent],...
    [zeros(N1,1)+cent;ones(N2,1);zeros(N1,1)+cent;ones(N2,1)]];
X(:,4) = X(:,2).*X(:,3);

%% PEB_2x2 group-level

PEB_entropy = spm_dcm_peb(GCM,X,{'B'});
PEB_expertise = spm_dcm_peb(GCM,X(:,[1,3,2,4]),{'B'});
PEB_interaction = spm_dcm_peb(GCM,X(:,[1,4,2,3]),{'B'});

%% Effect of entropy:

fam_probs = table(connections',zeros(4,1),zeros(4,1),zeros(4,1),zeros(4,1));
fam_probs.Properties.VariableNames = {'family','MMN','predictability','expertise','interaction'};

% single-model comparisons
[BMA_entropy, BMR_entropy] = spm_dcm_peb_bmc(PEB_entropy,templates);
%spm_dcm_peb_review(BMA_entropy,GCM);

[BMA_entropy_sort, BMA_entropy_idx] = sort(sum(BMA_entropy.P*-1));
BMA_entropy_table = cell2table([names(BMA_entropy_idx)',num2cell(BMA_entropy_sort*-1)']);

%writetable(BMA_entropy_table,'model_comp_predictability.csv')

%family comparisons
fam_entropy = [];
fam_entropy_BMA = [];

for c = 1:length(connections)
    cc = connections{c};
    [fam_entropy_BMA.(cc),fam_entropy.(cc)] = spm_dcm_peb_bmc_fam(BMA_entropy, BMR_entropy,families(c,:), 'ALL');
    fam_probs.predictability(c) = sum(fam_entropy.(cc).family.post(:,2) );
end
%% Effect of expertise:

[BMA_expertise, BMR_expertise] = spm_dcm_peb_bmc(PEB_expertise,templates);
%spm_dcm_peb_review(BMA_expertise,GCM);

[BMA_expertise_sort, BMA_expertise_idx] = sort(sum(BMA_expertise.P*-1));
BMA_expertise_table = cell2table([names(BMA_expertise_idx)',num2cell(BMA_expertise_sort*-1)']);

%writetable(BMA_expertise_table,'model_comp_expertise.csv')

%family comparisons
fam_expertise = [];
fam_expertise_BMA = [];

for c = 1:length(connections)
    cc = connections{c};
    [fam_expertise_BMA.(cc),fam_expertise.(cc)] = spm_dcm_peb_bmc_fam(BMA_expertise, BMR_expertise,families(c,:), 'ALL');
    fam_probs.expertise(c) = sum(fam_expertise.(cc).family.post(:,2) );
end
%% Interaction

[BMA_interaction, BMR_interaction] = spm_dcm_peb_bmc(PEB_interaction,templates);
%spm_dcm_peb_review(BMA_interaction,GCM);

[BMA_interaction_sort, BMA_interaction_idx] = sort(sum(BMA_interaction.P*-1));
BMA_interaction_table = cell2table([names(BMA_interaction_idx)',num2cell(BMA_interaction_sort*-1)']);

%writetable(BMA_interaction_table,[out_dir,'model_comp_interaction.csv'])

%family comparisons
fam_interaction = [];
fam_interaction_BMA = [];

for c = 1:length(connections)
    cc = connections{c};
    [fam_interaction_BMA.(cc),fam_interaction.(cc)] = spm_dcm_peb_bmc_fam(BMA_interaction, BMR_interaction,families(c,:), 'ALL');
    fam_probs.interaction(c) = sum(fam_interaction.(cc).family.post(:,2) );
end

%% Commonalities
[BMA_common_sort, BMA_common_idx] = sort(sum(BMA_entropy.P*-1,2));
BMA_common_table = cell2table([names(BMA_common_idx)',num2cell(BMA_common_sort*-1)]);
% writetable(BMA_common_table,[out_dir,'model_comp_common.csv'])

%% Put together family comparisons and save
for c = 1:length(connections)
    cc = connections{c};
    fam_probs.MMN(c) = sum(fam_entropy.(cc).family.post(2,:) );
end

writetable(fam_probs,[out_dir,'family_comp.csv'])

%% Bayesian model reduction
BMA_greedy = spm_dcm_peb_bmc(PEB_entropy);
%spm_dcm_peb_review(BMA_greedy,GCM);

%% Make joint report

com = sortrows(BMA_common_table);
ent = sortrows(BMA_entropy_table);
exp = sortrows(BMA_expertise_table);
int = sortrows(BMA_interaction_table);

joint_table = table();
joint_table.models = com.Var1;
joint_table.commonalities = com.Var2;
joint_table.entropy = ent.Var2;
joint_table.expertise = exp.Var2;
joint_table.interaction = int.Var2;

writetable(joint_table,[out_dir,'model_comp_joint_report.csv'])

%% Extract parameter values
par_names = {'rA1_rA1'; 'rA1_rSTG';'lA1_lA1';'lA1_lSTG';'rSTG_rA1';
    'rSTG_rSTG';'rSTG_rFOP';'lSTG_lA1';'lSTG_lSTG';'rFOP_rSTG';'rFOP_rFOP'};
BMA_pars = table(par_names,BMA_entropy.Ep(1:11,1),BMA_entropy.Cp(1:11,1),BMA_entropy.Pw',...
    BMA_entropy.Ep(12:22,1),BMA_entropy.Cp(12:22,1),BMA_entropy.Px',...
    BMA_expertise.Ep(12:22,1),BMA_expertise.Cp(12:22,1),BMA_expertise.Px',...
    BMA_interaction.Ep(12:22,1),BMA_interaction.Cp(12:22,1),BMA_interaction.Px');
BMA_pars_vnames = {'parameter_name','MMN_mu','MMN_var','MMN_prob',...
    'entropy_mu','entropy_var','entropy_prob',...
    'expertise_mu','expertise_var','expertise_prob',...
    'interaction_mu','interaction_var','interaction_prob'};

BMA_pars.Properties.VariableNames = BMA_pars_vnames;

writetable(BMA_pars,[out_dir,'BMA_parameters.csv'])

greedy_cov = spdiags(BMA_greedy.Cp);
BMA_pars_greedy = table(par_names,BMA_greedy.Ep(1:11,1),greedy_cov(1:11,1),BMA_greedy.Pp(1:11,1),...
    BMA_greedy.Ep(12:22,1),greedy_cov(12:22,1),BMA_greedy.Pp(12:22,1),...
    BMA_greedy.Ep(23:33,1),greedy_cov(23:33,1),BMA_greedy.Pp(23:33,1),...
    BMA_greedy.Ep(34:44,1),greedy_cov(34:44,1),BMA_greedy.Pp(34:44,1));

BMA_pars_greedy.Properties.VariableNames = BMA_pars_vnames;

writetable(BMA_pars_greedy,[out_dir,'BMA_parameters_greedy.csv'])

%% Get reconstructed signal
grand_avg = [];
for sub = 1:(N1+N2)
    curr_LP.DCM = [];
    curr_HP.DCM = [];
    curr_HP.DCM = GCM{sub};
    curr_LP.DCM = GCM{sub+(N1+N2)};
    if sub == 1
        time = curr_LP.DCM.xY.pst;
    end
    grand_avg.LP.s.pred(:,:,sub) = (curr_LP.DCM.H{1})*curr_LP.DCM.M.U';
    grand_avg.LP.d.pred(:,:,sub) = (curr_LP.DCM.H{2})*curr_LP.DCM.M.U';
    grand_avg.LP.diff.pred(:,:,sub) = grand_avg.LP.d.pred(:,:,sub) - grand_avg.LP.s.pred(:,:,sub);
    
    grand_avg.HP.s.pred(:,:,sub) = (curr_HP.DCM.H{1})*curr_HP.DCM.M.U';
    grand_avg.HP.d.pred(:,:,sub)= (curr_HP.DCM.H{2})*curr_HP.DCM.M.U';
    grand_avg.HP.diff.pred(:,:,sub)= grand_avg.HP.d.pred(:,:,sub)- grand_avg.HP.s.pred(:,:,sub);
    
    grand_avg.LP.s.obs(:,:,sub) = (curr_LP.DCM.H{1} + curr_LP.DCM.R{1})*curr_LP.DCM.M.U';
    grand_avg.LP.d.obs(:,:,sub) = (curr_LP.DCM.H{2} + curr_LP.DCM.R{2})*curr_LP.DCM.M.U';
    grand_avg.LP.diff.obs(:,:,sub) = grand_avg.LP.d.obs(:,:,sub) - grand_avg.LP.s.obs(:,:,sub);
    
    grand_avg.HP.s.obs(:,:,sub) = (curr_HP.DCM.H{1} + curr_HP.DCM.R{1})*curr_HP.DCM.M.U';
    grand_avg.HP.d.obs(:,:,sub)= (curr_HP.DCM.H{2} + curr_HP.DCM.R{2})*curr_HP.DCM.M.U';
    grand_avg.HP.diff.obs(:,:,sub)= grand_avg.HP.d.obs(:,:,sub)- grand_avg.HP.s.obs(:,:,sub);
end

%% Plot reconstructed signal
groups = {'NON-MUSICIANS','MUSICIANS','ALL'};
sub_idcs = {[1:20],[21:39],[1:39]};
conds = {'HP','LP'};
%lim = [-4*10^-3 4*10^-3];
lim = [-30 30];

xlimit = [0,300];
xlimit2 = [0,100];
xticks_labs  = {'0','50','100','150','200','250'};

for g = 1:length(groups)
    for c = 1:length(conds)
        sub_idx = sub_idcs{g};
        cond = conds{c};
        
        figure('Color','white');
        gg = gcf;
        
        
        set(gg, 'Units', 'normalized')
        set(gg, 'Renderer','painters')
        set(gg, 'Position', [0 0 0.8 0.8])
        set(gca,'fontsize',14)
        set(gg, 'PaperOrientation', 'portrait')
        %set(gg, 'PaperUnits', 'normalized')
        %set(gg, 'PaperPosition', [0 0 10 9])
        %set(gg, 'PaperSize', [10 9])
        
        subplot(3,4,1)
        plot(time,mean(grand_avg.(cond).s.obs(:,:,sub_idx),3)./10^-3);
        title('regular sound','FontSize',12)
        ylim(lim);
        xlim(xlimit)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        subplot(3,4,5)
        plot(time,mean(grand_avg.(cond).d.obs(:,:,sub_idx),3)./10^-3);
        ylim(lim);
        xlim(xlimit)
        title('surprising sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        subplot(3,4,9)
        plot(time,mean(grand_avg.(cond).diff.obs(:,:,sub_idx),3)./10^-3);
        ylim(lim);
        xlim(xlimit)
        title('surprising - regular','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        s2 = subplot(3,4,2);
        imagesc(mean(grand_avg.(cond).s.obs(:,:,sub_idx),3)'./10^-3,lim);
        title('regular sound','FontSize',12)
        xlim([0,65])
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        s2 = subplot(3,4,6);
        imagesc(mean(grand_avg.(cond).d.obs(:,:,sub_idx),3)'./10^-3,lim);
        title('surprising sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        s2 = subplot(3,4,10);
        imagesc(mean(grand_avg.(cond).diff.obs(:,:,sub_idx),3)'./10^-3,lim);
        title('surprising - regular','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        subplot(3,4,3)
        plot(time,mean(grand_avg.(cond).s.pred(:,:,sub_idx),3,'omitnan')./10^-3);
        ylim(lim);
        xlim(xlimit)
        title('regular sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        subplot(3,4,7)
        plot(time,mean(grand_avg.(cond).d.pred(:,:,sub_idx),3,'omitnan')./10^-3);
        ylim(lim);
        xlim(xlimit)
        title('surprising sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        subplot(3,4,11)
        plot(time,mean(grand_avg.(cond).diff.pred(:,:,sub_idx),3,'omitnan')./10^-3);
        ylim(lim);
        xlim(xlimit)
        title('surprising - regular','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('amplitude (fT)','FontSize',12)
        
        s2 = subplot(3,4,4);
        imagesc(mean(grand_avg.(cond).s.pred(:,:,sub_idx),3,'omitnan')'./10^-3,lim);
        title('regular sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        s2 = subplot(3,4,8);
        imagesc(mean(grand_avg.(cond).d.pred(:,:,sub_idx),3,'omitnan')'./10^-3,lim);
        title('surprising sound','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        s2 = subplot(3,4,12);
        imagesc(mean(grand_avg.(cond).diff.pred(:,:,sub_idx),3,'omitnan')'./10^-3,lim);
        title('surprising - regular','FontSize',12)
        xlabel('time','FontSize',12)
        ylabel('channels','FontSize',12)
        set(s2,'xTick',[0,14,27,39,52,65]);
        set(s2,'XTickLabel',xticks_labs);
        
        annotation('textbox',[0.25,0.9,0.5,0.1],'String',...
            [groups{g} ' - ' cond],'Edgecolor','none','FontSize',18,...
            'HorizontalAlignment','center')
        annotation('textbox',[0.265,0.89,0.1,0.1],'String',...
            ['observed'],'Edgecolor','none','FontSize',18,...
            'HorizontalAlignment','center')
        annotation('textbox',[0.68,0.89,0.1,0.1],'String',...
            ['predicted'],'Edgecolor','none','FontSize',18,...
            'HorizontalAlignment','center')
        print([fig_dir,...
            groups{g} '_' cond],'-dpng')
        print([fig_dir,...
            groups{g} '_' cond],'-dpdf')
    end
end
close all

%% topomaps
channs = GCM{1,1}.xY.name;
times = GCM{1,1}.xY.Time;
load(GCM{1,1}.xY.Dfile)
groups = {'non-musicians','musicians'};%,'ALL'};
sub_idcs = {[1:20],[21:40]};%,[1:40]};
conds = {'HP','LP'};

dummy = [];
dummy.dimord = 'chan_time';
dummy.label = channs;
dummy.time  = times(times>=0 & times <= 300);
dummy.grad = D.sensors.meg;
cfg = [];
cfg.parameter = 'avg';
cfg.comment = 'no';
cfg.gridscale = 200;
%cfg.layout = 'neuromag306mag.lay';
cfg.xlim = [175, 210];
cfg.marker = 'off';
cfg.style = 'both_imsat';
% factor to scale the data:

scf = 3;
figure('Color','white');
gg = gcf;
set(gg, 'Units', 'normalized')
set(gg, 'Renderer','painters')
set(gg, 'Position', [0 0 0.8 0.8])
set(gca,'fontsize',14)
set(gg, 'PaperOrientation', 'landscape')
set(gg, 'PaperUnits', 'centimeters')
set(gg, 'PaperPosition', [0 0 25 15])
set(gg, 'PaperSize', [25 15])
for g = 1:length(groups)
    group = groups{g};
    for c = 1:length(conds)
        sub_idx = sub_idcs{g};
        cond = conds{c};
        
        cfg.zlim = [-25 25]*scf;
        dummy.avg = mean(grand_avg.(cond).diff.obs(:,:,sub_idx),3).*(scf/10^-3);
        ax = subplot(2,4,4*(g-1) + c);
        ft_topoplotER(cfg, dummy);
        if c == 1 & g == 1
            cbar = colorbar();
            cbar.Location = 'south';
            cbar.Position = [ax.Position(1)+0.11,ax.Position(2)-0.1,ax.Position(3),0.04];
            cbar.Label.String = 'fT';
            aa = annotation('textarrow',[0,0],[0,0],'String','observed',...
                'HeadStyle','none','LineStyle','none','FontSize',16);
            set(aa,'Position',[ax.Position(1) + 0.18, ax.Position(2)+0.35,0.02,0.2])
            set(aa,'VerticalAlignment','middle')
            set(aa,'HorizontalAlignment','center')
        end
        if c == 1
            aa = annotation('textarrow',[0,0],[0,0],'String',group,...
                'HeadStyle','none','LineStyle','none','FontSize',16,...
                'TextRotation',90);
            set(aa,'Position',[ax.Position(1) - 0.025, ax.Position(2)+0.15,0.02,0.2])
            set(aa,'VerticalAlignment','middle')
            set(aa,'HorizontalAlignment','center')
        end
        if g == 2
            aa = annotation('textarrow',[0,0],[0,0],'String',cond,...
                'HeadStyle','none','LineStyle','none','FontSize',16);
            set(aa,'Position',[ax.Position(1)+0.08, ax.Position(2)-0.025,0.02,0.2])
            set(aa,'VerticalAlignment','middle')
            set(aa,'HorizontalAlignment','center')
        end
        cfg.zlim = [-15 15]*scf;
        ax = subplot(2,4,4*(g-1) + c + 2);
        dummy.avg = mean(grand_avg.(cond).diff.pred(:,:,sub_idx),3).*(scf/10^-3);
        ft_topoplotER(cfg, dummy);
        
        if c == 1 & g == 1
            cbar = colorbar();
            cbar.Location = 'south';
            cbar.Position = [ax.Position(1)+0.11,ax.Position(2)-0.1,ax.Position(3),0.04];
            cbar.Label.String = 'fT';
            aa = annotation('textarrow',[0,0],[0,0],'String','predicted',...
                'HeadStyle','none','LineStyle','none','FontSize',16);
            set(aa,'Position',[ax.Position(1) + 0.18, ax.Position(2)+0.35,0.02,0.2])
            set(aa,'VerticalAlignment','middle')
            set(aa,'HorizontalAlignment','center')
        end
        
        if g == 2
            aa = annotation('textarrow',[0,0],[0,0],'String',cond,...
                'HeadStyle','none','LineStyle','none','FontSize',16);
            set(aa,'Position',[ax.Position(1)+0.08, ax.Position(2)-0.025,0.02,0.2])
            set(aa,'VerticalAlignment','middle')
            set(aa,'HorizontalAlignment','center')
        end
    end
end

print([fig_dir,'topomaps_obs_vs_pred'],'-dpng')
print([fig_dir,'topomaps_obs_vs_pred'],'-dpdf')

%% Channel selection plots

channs = GCM{1,1}.xY.name;
times = GCM{1,1}.xY.Time;
times  = times(times>=0 & times <= 300);
groups = {'non-musicians','musicians'};%,'ALL'};
sub_idcs = {[1:20],[21:40]};%,[1:40]};
conds = {'HP','LP'};
hems = {'Left','Right'};
hem_channs = {{'MEG1621','MEG1611','MEG0231','MEG0241'},...
    {'MEG2421','MEG2411','MEG1331','MEG1341'}};
types = {'obs','pred'};
typenames = {'observed','predicted'};
% factor to scale the data:
ylims = {[-110,110],[-70,70]};
scf = 3;
figure('Color','white');
gg = gcf;
set(gg, 'Units', 'normalized')
set(gg, 'Renderer','painters')
set(gg, 'Position', [0 0 0.8 0.8])
set(gca,'fontsize',12)
set(gg, 'PaperOrientation', 'landscape')
set(gg, 'PaperUnits', 'centimeters')
set(gg, 'PaperPosition', [0 0 25 18])
set(gg, 'PaperSize', [25 18])

for c = 1:length(conds)
    cond = conds{c};
    for h = 1:length(hems)
        hem = hems{h};
        cchans = hem_channs{h};
        chidx = find(ismember(channs,cchans));
        for t = 1:length(types)
            type = types{t};
            cfg.ylim = [-25 25]*scf;
            avg_nmus = mean(mean(grand_avg.(cond).diff.(type)(:,chidx,1:20),2),3).*(scf/10^-3);
            se_nmus = (std(mean(grand_avg.(cond).diff.(type)(:,chidx,1:20),2),[],3).*(scf/10^-3))/sqrt(20);
            upper_nmus = avg_nmus + 1.96*se_nmus;
            lower_nmus = avg_nmus - 1.96*se_nmus;
            
            avg_mus = mean(mean(grand_avg.(cond).diff.(type)(:,chidx,21:40),2),3).*(scf/10^-3);
            se_mus = (std(mean(grand_avg.(cond).diff.(type)(:,chidx,21:40),2),[],3).*(scf/10^-3))/sqrt(20);
            upper_mus = avg_mus + 1.96*se_mus;
            lower_mus = avg_mus - 1.96*se_mus;
            terror = [times,fliplr(times)];
            
            ax = subplot(2,4,4*(c-1) + t + 2*(h-1));
            fill(terror,[lower_mus',fliplr(upper_mus')],'r','LineStyle','none');hold on;
            alpha(.1)
            fill(terror,[lower_nmus',fliplr(upper_nmus')],'b','LineStyle','none');hold on;
            alpha(.1)
            hold on;
            pnmus = plot(times,avg_nmus,'color','b','LineWidth',1.5); hold on
            pmus = plot(times,avg_mus,'color','r','LineWidth',1.5); hold on
            hline(0, 'color','k')
            ylim(ylims{t})
            xlim([0,300])
            if t == 1 & h == 1 & c == 1
                lgd = legend([pmus,pnmus],{'musicians','non-musicians'},...
                    'Orientation','horizontal','Box','off','Position',...
                    [0.5,0.4,0.05,0.2],'FontSize',12);
                xlabel('Time (ms)')
                ylabel('Field strength (fT)')
                
            end
            if t == 1 & h == 1
                aa = annotation('textarrow',[0,0],[0,0],'String',cond,...
                    'HeadStyle','none','LineStyle','none','FontSize',14);
                set(aa,'Position',[ax.Position(1)+.01,...
                    ax.Position(2)+0.36,0.02,0.2])
                set(aa,'VerticalAlignment','middle')
                set(aa,'HorizontalAlignment','center')
            end
            if t==1 & c == 1
                aa = annotation('textarrow',[0,0],[0,0],'String',[hem ' hemisphere'],...
                    'HeadStyle','none','LineStyle','none','FontSize',14);
                set(aa,'Position',[ax.Position(1)+.18,...
                    ax.Position(2)+0.38,0.02,0.2])
                set(aa,'VerticalAlignment','middle')
                set(aa,'HorizontalAlignment','center')
            end
            if c == 2
                aa = annotation('textarrow',[0,0],[0,0],'String',typenames{t},...
                    'HeadStyle','none','LineStyle','none','FontSize',14);
                set(aa,'Position',[ax.Position(1)+ .08,...
                    ax.Position(2)+-0.05,0.02,0.2])
                set(aa,'VerticalAlignment','middle')
                set(aa,'HorizontalAlignment','center')
                
            end
        end
    end
end

print([fig_dir,'channsel_obs_vs_pred'],'-dpng')
print([fig_dir,'channsel_obs_vs_pred'],'-dpdf')

end



