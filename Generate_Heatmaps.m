% Before running this script, please load a .mat file output of the
% "Run_Model.m" script. This script will then produce three 'heatmaps',
% plotting the equilibrium: (1) number of beard colours; (2) helper
% frequency; (3) nonbeard frequency. In the main text, our figures 2 and 3
% are produced as merged summaries of these three heatmaps.

% THE X AND Y AXES NEED TO BE SET MANUALLY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To produce the heatmaps underpinning Figure 2, load one of the .mat files 
% beginning 'Fig2_...' and set xR=alphaR, yR=dR, xLabelStr='\alpha', 
% yLabelStr='d'. To produce the heatmaps underpinning Figure 3a, load one
% of the .mat files beginning 'Fig3a_...' and set xR=FR, yR=bR, 
% xLabelStr='F', yLabelStr='b'.
xR = FR; % x axis range
yR = bR; % y axis range
xLabelStr = 'F'; % x axis label
yLabelStr = 'b'; % y axis label

figure('Color','w','Position',[100 100 900 1100])

% Tick spacing
yspace = linspace(min(yR), max(yR), 6);
xspace = linspace(min(xR), max(xR), 6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A) BEARD COLOURS HEATMAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,1)

imagesc(xR, yR, (1-nonbeardfreq)./avgtagfreq)
set(gca,'YDir','normal','FontSize',11,'LineWidth',1)
colormap(gca, parula)

caxis([1 Lmax])
cb = colorbar;
cb.Ticks = [1, 1+(Lmax-1)/2, Lmax];

title('Beard Colours','FontWeight','bold')
xlabel(xLabelStr)
ylabel(yLabelStr)
xticks(xspace)
yticks(yspace)
xticklabels(compose('%.3g', xspace))
yticklabels(compose('%.3g', yspace))
box on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B) HELPER FREQUENCY HEATMAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,2)

imagesc(xR, yR, resalt)
set(gca,'YDir','normal','FontSize',11,'LineWidth',1)
colormap(gca, parula)

caxis([0 1])
cb = colorbar;
cb.Ticks = [0, 0.5, 1];

title('Helper Frequency','FontWeight','bold')
xlabel(xLabelStr)
ylabel(yLabelStr)
xticks(xspace)
yticks(yspace)
xticklabels(compose('%.3g', xspace))
yticklabels(compose('%.3g', yspace))
box on

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C) NON-BEARD FREQUENCY HEATMAP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(3,1,3)

imagesc(xR, yR, nonbeardfreq)
set(gca,'YDir','normal','FontSize',11,'LineWidth',1)
colormap(gca, parula)

caxis([0 1])
cb = colorbar;
cb.Ticks = [0, 0.5, 1];

title('Non-Beard Frequency','FontWeight','bold')
xlabel(xLabelStr)
ylabel(yLabelStr)
xticks(xspace)
yticks(yspace)
xticklabels(compose('%.3g', xspace))
yticklabels(compose('%.3g', yspace))
box on