cd 'C:\Users\au571303\Documents\projects\DCM_entropy';
addpath C:\Users\au571303\Documents\MATLAB\spm12\toolbox\cat12
clear all
close all
surface = 'C:\Users\au571303\Documents\MATLAB\spm12\canonical/cortex_20484.surf.gii'; %Higher res, slower plotting
M = gifti(surface);
stats_dir = 'source_stats/';

views = [90,-90];
%lights = {'right','left'};
lights = {[30,0],[-30,0]};

% conditions = {'Standards','MMN'};
% contrasts = {'standard_thresh.nii','deviance_unthresh.nii'};

conditions = {'MMN'};
contrasts = {'deviance_unthresh.nii'};

%contrasts = {'spmT_0009.nii','spmT_0007.nii'};

spm('defaults', 'EEG');

% close all
%% Then plot surfaces
cm = colormap('hot');
%cm = repmat([1,0,0],length(cm),1);
figure;
set(gcf,'color','white')
set(gcf,'renderer','painters')
set(gcf,'PaperOrientation','portrait')
set(gcf,'PaperUnits','normalized')
set(gcf, 'PaperPosition',[0,0,0.8,0.4])
set(gcf, 'Units','normalized')
set(gcf, 'Position',[0,0,0.8,0.4])

count = 0;
 for c = 1:length(conditions)
    cond  = conditions{c};   
    results = [stats_dir contrasts{c}];
    P = spm_mesh_project(M, results);
   
    for v = 1:length(views)
        count = count +1;
        Y = subplot(length(conditions),2,count);
        H = cat_surf_render(surface, 'Parent',Y);
        cat_surf_render('Overlay',H,P);
        cat_surf_render('ColourBar',H,'on');
        cat_surf_render('ColourMap',H,cm);
        cat_surf_render('Clim',H,[2.5 6.5]);
        spm_mesh_inflate(H.patch,Inf,1);
        spm_mesh_inflate(H.patch,Inf,1);
        view(views(v),0)
       % camlight(lights{v}(1),lights{v}(2))
        camlight('headlight')
    end
 end
print('MMN_sources.pdf','-dpdf','-r600')
print('MMN_sources.png','-dpng','-r300')
