% closely follow up with d1_fig4_0_other.m

clc;

% change green to light green
% colors_here = [128,64,230; 200, 200, 200; 163, 194, 255; 230,128,0; 34,200,0]/255;
colors_here = [128,64,230; 200, 200, 200; 163, 194, 255; 230,128,0; 34,200,0; 40,40,40]/255;

% get the variables to show
vars_global = [NBP_ts_y, GPP_ts_y, AR_ts_y, HR_ts_y, Fire_ts_y, Harvest_ts_y];
vars_tropic = [NBP_ts_y_mask(:,1), GPP_ts_y_mask(:,1), AR_ts_y_mask(:,1), HR_ts_y_mask(:,1), Fire_ts_y_mask(:,1), Harvest_ts_y_mask(:,1)];    % 86*6
vars_boreal = [NBP_ts_y_mask(:,2), GPP_ts_y_mask(:,2), AR_ts_y_mask(:,2), HR_ts_y_mask(:,2), Fire_ts_y_mask(:,2), Harvest_ts_y_mask(:,2)];    % 86*6

%% visualization 1. NBP partitioning
% NBP GPP AR HR FIRE HARVEST

figure('Position',[10 10 1300 280]);
colororder(colors_here);
FaceAlpha_here_above = 0.40;

a1 = subplot(1,3,1);
hold on;
% aa1 = area(vars_congo(:,2),'FaceColor',colors_here(1,:),'EdgeColor','none','FaceAlpha',FaceAlpha_here);
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
aa2 = area(vars_global(:,3:6),'EdgeColor','none','FaceAlpha',FaceAlpha_here_above);
aa1 = plot(vars_global(:,2),'Color',colors_here(5,:),'LineWidth',1);
xlim([1 86]);
% ylim([0 175]);
ylim([0 350]);
xticks([1 10 16:10:86]);
% yticks(0:25:350);
yticks(0:50:350);
% yticklabels({'0','','50','','100','','150',''});
yticklabels({'0','','100','','200','','300',''});
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Carbon fluxes (GtC/year)'})
a1.YGrid = 'on';

yyaxis right;
p1_0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
p1 = plot(vars_global(:,1),'LineWidth',1.2,'Color',[0.15 0.15 0.15]);
xlim([1 86]);
ylim([-30 40]);
yticks(-10:10:10);
% yticklabels({'-10','-5','0','5','10'})
% ylim([-15 20]);
% yticks(-10:5:10);
% yticklabels({'-10','-5','0','5','10'})
ylabel({'NBP (GtC/year)'})

box off;
% legend
l = legend([aa1 p1 aa2(1:4)],'GPP','NBP','AR','HR','Fire','Harvest');
l.Box = 'off';
l.Location = 'northeast';
l.FontSize = 9;
l.NumColumns = 2;
% title
tt = title('A Global','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a1 = subplot(1,3,2);
hold on;
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
aa2 = area(vars_tropic(:,3:6),'EdgeColor','none','FaceAlpha',FaceAlpha_here_above);
aa1 = plot(vars_tropic(:,2),'Color',colors_here(5,:),'LineWidth',1);
% p1 = plot(vars_tropic(:,1),'LineWidth',1.5);
xlim([1 86]);
ylim([0 350]);
xticks([1 10 16:10:86]);
yticks(0:50:350);
yticklabels({'0','','100','','200','','300',''})
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
% ylabel({'NBP and its partitioning';'(GtC/year)'})
a1.YGrid = 'on';

yyaxis right;
p1_0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
p1 = plot(vars_tropic(:,1),'LineWidth',1.2,'Color',[0.15 0.15 0.15]);
ylim([-30 40]);
yticks(-20:10:20);
yticklabels({'-20','-10','0','10','20'})
ylabel({'NBP (GtC/year)'})

% title
tt = title('B Tropical','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a1 = subplot(1,3,3);
hold on;
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
aa2 = area(vars_boreal(:,3:6),'EdgeColor','none','FaceAlpha',FaceAlpha_here_above);
aa1 = plot(vars_boreal(:,2),'Color',colors_here(5,:),'LineWidth',1);
% p1 = plot(vars_boreal(:,1),'LineWidth',1.5);
xlim([1 86]);
% ylim([0 175]);
ylim([0 350]);
xticks([1 10 16:10:86]);
% yticks(0:25:350);
yticks(0:50:350);
% yticklabels({'0','','50','','100','','150',''})
yticklabels({'0','','100','','200','','300',''})
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
a1.YGrid = 'on';

yyaxis right;
p1_0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
p1 = plot(vars_global(:,1),'LineWidth',1.2,'Color',[0.15 0.15 0.15]);
% ylim([-15 20]);
ylim([-30 40]);
% yticks(-10:5:10);
yticks(-10:10:10);
% yticklabels({'-10','-5','0','5','10'})
yticklabels({'-10','0','10'})
ylabel({'NBP (GtC/year)'})

% title
tt = title('C Boreal','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

%% visualization 2. LAI(Tree structure) and climatic factors
% c.f. E:\research\D_CDR\2311_12\codes_2311\b2_structure_LAI.m
% LAI, TSA, SOILWATER_10CM

% color in fig1
color_here = [128,64,230; 26,166,64]/255;

figure('Position',[10 10 1300 280]);
colororder(color_here);

a1 = subplot(1,3,1);
hold on;
% aa1 = area(vars_congo(:,2),'FaceColor',colors_here(1,:),'EdgeColor','none','FaceAlpha',FaceAlpha_here);
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
p1 = plot(TLAI_ts_y,'LineWidth',1,'Color',[0 0 0]);
p2 = plot(TLAI_ts_y_mask,'LineWidth',1);
hold off;
xlim([1 86]);
ylim([1 4]);
xticks([1 10 16:10:86]);
yticks(1:4);
yticklabels({'1','2','3','4'});
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'LAI'})
a1.YGrid = 'on';
% position: 0.13,0.138245622260863,0.187304347107163,0.786754377739137
set(a1,'Position',[0.13,0.138245622260863,0.187304347107163,0.786754377739137])
% legend
l = legend([p1 p2(1) p2(2)],'Global','Tropical','Boreal');
l.Box = 'off';
l.Location = 'northeast';
l.FontSize = 10;
% title
tt = title('D Leaf area index','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a1 = subplot(1,3,2);
hold on;
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
hold on;
p1 = plot(TSA_ts_y,'LineWidth',1,'Color',[0 0 0]);
p2 = plot(TSA_ts_y_mask(:,1),'LineWidth',1);
% hold off
% p1 = plot(vars_tropic(:,1),'LineWidth',1.5);
xlim([1 86]);
ylim([10 30]);
xticks([1 10 16:10:86]);
yticks(10:5:30);
% yticklabels({'0','10','20','30','40'});
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Air temperature (^{o}C)'})
a1.YGrid = 'on';
yyaxis right;
p2 = plot(TSA_ts_y_mask(:,2),'LineWidth',1);
ylim([0 20]);
yticks(0:5:20);
% sxes postion
set(a1,'Position',[0.410797101449275,0.138245622260863,0.187304347107163,0.786754377739137]);
box off;
% legend
% l = legend([p1 p2(1) p2(2)],'Global','Tropical','Boreal');
% l.Box = 'off';
% l.Location = 'northeast';
% l.FontSize = 10;
% title
tt = title('E 2-m air temperature','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a1 = subplot(1,3,3);
hold on;
p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
hold on;
p1 = plot(SOILWATER_10CM_ts_y,'LineWidth',1,'Color',[0 0 0]);
p2 = plot(SOILWATER_10CM_ts_y_mask(:,1),'LineWidth',1);
xlim([1 86]);
ylim([28 34]);
xticks([1 10 16:10:86]);
yticks(28:2:34);
% yticklabels({'50','','100','','150',''})
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Soil water content (kg/m^2)'});
a1.YGrid = 'on';
yyaxis right;
p2 = plot(SOILWATER_10CM_ts_y_mask(:,2),'LineWidth',1);
ylim([38 44]);
yticks(38:2:44);
% axes position
set(a1,'Position',[0.691594202898551,0.138245622260863,0.187304347107163,0.786754377739137]);
box off;
hold off
% legend
% l = legend([p1 p2(1) p2(2)],'Global','Tropical','Boreal');
% l.Box = 'off';
% l.Location = 'northeast';
% l.FontSize = 10;
% title
tt = title('F 10 cm soil water','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

