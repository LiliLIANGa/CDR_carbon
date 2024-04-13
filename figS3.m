% here shows the rainforest domains, and their NPP (GPP, AR, HR)

clear;
clc;

% load data
p = 'E:\research\D_CDR\2309\procData';
addpath(p);
clear p;

% time index
load procData\days_of_month.mat;
days_of_month_2015 = days_of_month(1:108,:);
days_of_month_2100 = days_of_month(109:end,:);
date_yy_all = unique(days_of_month(:,1),"rows");
date_yy_2015 = unique(days_of_month_2015(:,1),"rows");
date_yy_2100 = unique(days_of_month_2100(:,1),"rows");

load procData\landmask_lnd.mat;
load procData\pftmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
landmask_lnd(:,1:33) = nan;
landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;

% ---> group different climate
% 1: tropical: 1:3
% 2: Arid: 4:7
% 3: Temperate: 8:16
% 4: Cold: 17:28 (Boreal)
% 5: Polar: 29:30
load procData_2311\KG_classes.mat;
% ---> rainforest masks
% 1: Congo
% 2: Southeast Asia
% 3: Amazon
load procData_2311\rainforest_mask.mat;

%% 1. NBP

% load main data of C fluxes
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);
% calculate the cumulative sum
NBP_cum = cumsum(NBP_all,3);

NBP_RF_ts = nan(86,3);    % [years 2015-2100, climate zones 3]
NBP_cumulRF_ts = nan(86,3);
for i = 1:3
    % get the mask
    RF_mask = rainforest_mask == i;

    % get the area_weight
    RF_area_lnd = area_lnd.*RF_mask;
    RF_area_total = sum(RF_area_lnd,'all','omitnan');
    RF_area_weight = RF_area_lnd./RF_area_total;
    
    % get the weighted C flux & cumulative C
    for yy = 1:86
        NBP_RF_ts(yy,i) = squeeze(sum(NBP_all(:,:,yy).*RF_area_weight,'all','omitnan'));
        NBP_cumulRF_ts(yy,i) = squeeze(sum(NBP_cum(:,:,yy).*RF_area_weight,'all','omitnan'));
    end
end

%% 2. NPP (GPP, HR, AR, fire, harvest)

% load main data of C fluxes
load procData_2311\GPP_2015_y.mat;
load procData_2311\GPP_2100_y.mat;
load procData_2311\AR_2015_y.mat;
load procData_2311\AR_2100_y.mat;
load procData_2311\HR_2015_y.mat;
load procData_2311\HR_2100_y.mat;
GPP_all = cat(3,GPP_2015_y,GPP_2100_y);
AR_all = cat(3,AR_2015_y,AR_2100_y);
HR_all = cat(3,HR_2015_y,HR_2100_y);

load procData_2311\FIRE_CLOSS_2015_y.mat;
load procData_2311\FIRE_CLOSS_2100_y.mat;
load procData_2311\FIRE_CLOSS2_2015_y.mat;
load procData_2311\FIRE_CLOSS2_2100_y.mat;
load procData_2311\WOOD_HARVESTC_2015_y.mat;
load procData_2311\WOOD_HARVESTC_2100_y.mat;
FIRE_CLOSS_2015_y = FIRE_CLOSS_2015_y + FIRE_CLOSS2_2015_y;
FIRE_CLOSS_2100_y = FIRE_CLOSS_2100_y + FIRE_CLOSS2_2100_y;
Fire_all = cat(3,FIRE_CLOSS_2015_y,FIRE_CLOSS_2100_y);
Harvest_all = cat(3,WOOD_HARVESTC_2015_y,WOOD_HARVESTC_2100_y);

clear GPP_2015_y GPP_2100_y AR_2015_y AR_2100_y HR_2015_y HR_2100_y;
clear FIRE_CLOSS_2015_y FIRE_CLOSS2_2015_y FIRE_CLOSS_2100_y FIRE_CLOSS2_2100_y WOOD_HARVESTC_2015_y WOOD_HARVESTC_2100_y;

GPP_RF_ts = nan(86,3);    % [years 2015-2100, climate zones 3]
AR_RF_ts = nan(86,3);
HR_RF_ts = nan(86,3);
Fire_RF_ts = nan(86,3);
Harvest_RF_ts = nan(86,3);

for i = 1:3
    % get the mask
    RF_mask = rainforest_mask == i;

    % get the area_weight
    RF_area_lnd = area_lnd.*RF_mask;
    RF_area_total = sum(RF_area_lnd,'all','omitnan');
    RF_area_weight = RF_area_lnd./RF_area_total;
    
    % get the weighted C flux & cumulative C
    for yy = 1:86
        GPP_RF_ts(yy,i) = squeeze(sum(GPP_all(:,:,yy).*RF_area_weight,'all','omitnan'));
        AR_RF_ts(yy,i) = squeeze(sum(AR_all(:,:,yy).*RF_area_weight,'all','omitnan'));
        HR_RF_ts(yy,i) = squeeze(sum(HR_all(:,:,yy).*RF_area_weight,'all','omitnan'));
        Fire_RF_ts(yy,i) = squeeze(sum(Fire_all(:,:,yy).*RF_area_weight,'all','omitnan'));
        Harvest_RF_ts(yy,i) = squeeze(sum(Harvest_all(:,:,yy).*RF_area_weight,'all','omitnan'));
    end
end
NPP_RF_ts = GPP_RF_ts - AR_RF_ts - HR_RF_ts;

%% 1. visualization NBP
% Part 1: only fluxes

figure('Position',[10 10 1430 650]);
colororder(["#8040E6";"#1AA640";"#E68000"]);
% colororder(["#8040E6";"#000000";"#E68000"]);

a1 = subplot(2,3,1);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(NBP_RF_ts(:,1),'LineWidth',1);
xlim([1 86]);
ylim([-50 30]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
yticks([-40 -20 0 20])
ylabel({'NBP (GtC/year)'})
a1.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); NBP_cumulRF_ts(10:end,1) - NBP_cumulRF_ts(9,1)],'LineWidth',1,'Color','#1AA640');
hold off;
box off;
ylim([-500 300]);
yticks([-400 -200 0])
ylabel({'Cumulative NBP (GtC)'})
a1.YGrid = 'on';
% legend
ll = legend([p1, p2],{'NBP','Cumulative NBP'});
ll.Box = 'off';
% title
tt = title('A Congo rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
text(11,-456,'Abrupt reduction in CO_2 level in 2024','FontSize',10)

a2 = subplot(2,3,2);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(NBP_RF_ts(:,2),'LineWidth',1);
xlim([1 86]);
ylim([-50 30]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
yticks([-40 -20 0 20])
ylabel({'NBP (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); NBP_cumulRF_ts(10:end,2) - NBP_cumulRF_ts(9,2)],'LineWidth',1,'Color','#1AA640');
hold off;
box off;
ylim([-500 300]);
yticks([-400 -200 0])
ylabel({'Cumulative NBP (GtC)'})
a2.YGrid = 'on';
% title
tt = title('B Southeast Asia rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a3 = subplot(2,3,3);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(NBP_RF_ts(:,3),'LineWidth',1);
xlim([1 86]);
ylim([-50 30]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
yticks([-40 -20 0 20])
ylabel({'NBP (GtC/year)'})
a3.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); NBP_cumulRF_ts(10:end,3) - NBP_cumulRF_ts(9,3)],'LineWidth',1,'Color','#1AA640');
hold off;
box off;
ylim([-500 300]);
yticks([-400 -200 0])
ylabel({'Cumulative NBP (GtC)'})
a3.YGrid = 'on';
% title
tt = title('C Amazon rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

% 2. visualization NPP (GPP, HR, AR, fire, harvest)
% Part 1: only fluxes

% figure('Position',[10 10 1430 300]);
% colororder(["#8040E6";"#1AA640";"#E68000"]);
%              purple,     gray,          light blue,    orange,    light green, dark 
colors_here = [128,64,230; 200, 200, 200; 163, 194, 255; 230,128,0; 34,200,0; 40,40,40]/255;
colororder(colors_here);
% orange color in 
% colors = ['#ff5108', '#f9802d', '#FF9900'];

a1 = subplot(2,3,4);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_RF_ts(:,1),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_RF_ts(:,1),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_RF_ts(:,1),'LineWidth',1,'Color',[150,150,150]/255);
ylim([0 500]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a1.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_RF_ts(:,1),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_RF_ts(:,1),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_RF_ts(:,1),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-50 50]);
yticks([-30 -20 -10 0 10 20 30])
ylabel({'NPP & disturbances (GtC/year)'})
a1.YGrid = 'on';
% legend
ll = legend([p1, p1_2, p1_3, p2, p3, p4],{'GPP','AR','HR','Fire','Harvest','NPP'});
ll.Box = 'off';
ll.NumColumns = 2;
% title
tt = title('D Congo rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
text(11,-456,'Abrupt reduction in CO_2 level in 2024','FontSize',10)

a2 = subplot(2,3,5);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_RF_ts(:,2),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_RF_ts(:,2),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_RF_ts(:,2),'LineWidth',1,'Color',[150,150,150]/255);
ylim([0 500]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_RF_ts(:,2),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_RF_ts(:,2),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_RF_ts(:,2),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-50 50]);
yticks([-30 -20 -10 0 10 20 30])
ylabel({'NPP & disturbances (GtC/year)'})
a2.YGrid = 'on';
% title
tt = title('E Southeast Asia rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a3 = subplot(2,3,6);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_RF_ts(:,3),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_RF_ts(:,3),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_RF_ts(:,3),'LineWidth',1,'Color',[150,150,150]/255);
ylim([0 500]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a3.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_RF_ts(:,3),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_RF_ts(:,3),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_RF_ts(:,3),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-50 50]);
yticks([-30 -20 -10 0 10 20 30])
ylabel({'NPP & disturbances (GtC/year)'})
a3.YGrid = 'on';
% title
tt = title('F Amazon rainforest');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';



