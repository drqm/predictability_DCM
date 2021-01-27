addpath(genpath('C:\Users\au571303\Documents\MATLAB\BrainNetViewer'));
cd 'C:\Users\au571303\Documents\projects\DCM_entropy'

clear all
close all

f = figure;
set(f,'PaperSize',[60,30])
set(f,'Units','normalized')
set(f,'Position',[0 0 0.8 0.4])
set(f,'Position',[0 0 0.8 0.4])
set(f,'Color',[1 1 1])

ax{1} = subplot(1,2,1);
ax{2} = subplot(1,2,2);

hems = {'Right','Left'};
lights = {'right','left'};
cvs = {90,-90};

for h = 1:2
hem = hems{h};
light = lights{h};
cv = cvs{h};
f1 = ['Data/SurfTemplate/BrainMesh_ICBM152' hem '.nv'];
f2 = [hem '_nodes.node'];
f3 = [hem '_edges.edge'];
s = figure;
b = BrainNet_MapCfg(f1,f2,f3);
g = gca;
gch = get(g,'Children');
copyobj(gch,ax{h});

set(0, 'currentfigure', f); 
set(f, 'currentaxes', ax{h})
set(ax{h},'Visible','off')
cur_pos = get(ax{h},'Position');
cur_pos(3) = 0.45;
cur_pos(1) = cur_pos(1) - 0.06;
set(ax{h},'Position',cur_pos)
set(ax{h},'View', [cv,10])
if h == 1
camlight headlight
end
close(s)
close(b)
end
print('network','-dpng','-r600')
print('network','-dpdf','-r600')