% Here draws the figure with the same vertical axis.

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
% *************************************************************************
% ******************** This needs modification. ***************************
% *************************************************************************
NBP_KG_ts = nan(86,3);    % [years 2015-2100, climate zones 3]
NBP_cumulKG_ts = nan(86,3);
reg_index = [1 4];
for i = 1:3
    if i == 1
        % global
        % mask
        KG_area_weight = area_lnd./sum(area_lnd,'all','omitnan');
    else
        % get the mask: tropical and boreal
        RF_mask = KG_classes == reg_index(i-1);
    
        % get the area_weight
        KG_area_lnd = area_lnd.*RF_mask;
        KG_area_total = sum(KG_area_lnd,'all','omitnan');
        KG_area_weight = KG_area_lnd./KG_area_total;
    end
    % get the weighted C flux & cumulative C
    for yy = 1:86
        NBP_KG_ts(yy,i) = squeeze(sum(NBP_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        NBP_cumulKG_ts(yy,i) = squeeze(sum(NBP_cum(:,:,yy).*KG_area_weight,'all','omitnan'));
    end
end

%% 2. NPP (GPP, HR, AR, fire, harvest)

% c.f. E:\research\D_CDR\2311_12\d1_fig3_0.m

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

GPP_KG_ts = nan(86,3);    % [years 2015-2100, climate zones 3]
AR_KG_ts = nan(86,3);
HR_KG_ts = nan(86,3);
Fire_KG_ts = nan(86,3);
Harvest_KG_ts = nan(86,3);

for i = 1:3
    % get the weighted mask
    if i == 1
        % global
        KG_area_weight = area_lnd./sum(area_lnd,'all','omitnan');
    else
        % get the mask: tropical and boreal
        RF_mask = KG_classes == reg_index(i-1);
    
        % get the area_weight
        KG_area_lnd = area_lnd.*RF_mask;
        KG_area_total = sum(KG_area_lnd,'all','omitnan');
        KG_area_weight = KG_area_lnd./KG_area_total;
    end
    % get the weighted C flux & cumulative C
    for yy = 1:86
        GPP_KG_ts(yy,i) = squeeze(sum(GPP_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        AR_KG_ts(yy,i) = squeeze(sum(AR_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        HR_KG_ts(yy,i) = squeeze(sum(HR_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        Fire_KG_ts(yy,i) = squeeze(sum(Fire_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        Harvest_KG_ts(yy,i) = squeeze(sum(Harvest_all(:,:,yy).*KG_area_weight,'all','omitnan'));
    end
end
NPP_KG_ts = GPP_KG_ts - AR_KG_ts - HR_KG_ts;

%% 1. visualization NBP
% Part 1: only fluxes

figure('Position',[10 10 1430 300]);

colors_here = [128,64,230; 200, 200, 200; 163, 194, 255; 230,128,0; 34,200,0; 40,40,40]/255;
colororder(colors_here);

a1 = subplot(1,3,1);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_KG_ts(:,1),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_KG_ts(:,1),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_KG_ts(:,1),'LineWidth',1,'Color',[150,150,150]/255);
% ylim([0 200]);
ylim([0 400]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a1.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_KG_ts(:,1),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_KG_ts(:,1),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_KG_ts(:,1),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-20 20]);
yticks([-20 -10 0 10 20])
% ylim([-15 15]);
% yticks([-15 -7.5 0 7.5 15])
ylabel({'NPP & disturbances (GtC/year)'})
a1.YGrid = 'on';
% legend
ll = legend([p1, p1_2, p1_3, p2, p3, p4],{'GPP','AR','HR','Fire','Harvest','NPP'});
ll.Box = 'off';
ll.NumColumns = 2;
% title
tt = title('A Global');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
text(11,-456,'Abrupt reduction in CO_2 level in 2024','FontSize',10)

a2 = subplot(1,3,2);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_KG_ts(:,2),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_KG_ts(:,2),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_KG_ts(:,2),'LineWidth',1,'Color',[150,150,150]/255);
ylim([0 400]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_KG_ts(:,2),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_KG_ts(:,2),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_KG_ts(:,2),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-20 20]);
yticks([-20 -10 0 10 20])
% ylim([-30 30]);
% yticks([-30 -15 0 15 30])
ylabel({'NPP & disturbances (GtC/year)'})
a2.YGrid = 'on';
% title
tt = title('B Tropical');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a3 = subplot(1,3,3);
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',3);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(GPP_KG_ts(:,3),'LineWidth',1,'Color',[34,200,0]/255);
p1_2 = plot(AR_KG_ts(:,3),'LineWidth',1,'Color',[128,64,230]/255);
p1_3 = plot(HR_KG_ts(:,3),'LineWidth',1,'Color',[150,150,150]/255);
% ylim([0 200]);
ylim([0 400]);
% yticks([-40 -20 0 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'GPP AR HR (GtC/year)'})
a3.YGrid = 'on';
yyaxis right;
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',0.5);
p2 = plot(Fire_KG_ts(:,3),'LineWidth',1,'Color','#FFCC33','LineStyle','-');
p3 = plot(Harvest_KG_ts(:,3),'LineWidth',1,'Color','#FF8D33','LineStyle','-');
p4 = plot(NPP_KG_ts(:,3),'LineWidth',1,'Color','#FF542E','LineStyle','-');
hold off;
box off;
ylim([-20 20]);
yticks([-20 -10 0 10 20])
% ylim([-15 15]);
% yticks([-15 -7.5 0 7.5 15])
ylabel({'NPP & disturbances (GtC/year)'})
a3.YGrid = 'on';
% title
tt = title('C Boreal');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';


