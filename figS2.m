% Here we address one of Prof.Alan concerns.
% Extract the humid rainforest from the tropical region, and see how others
% do in CDR scenario, and see if there is interesting results.

% ref. E:\research\D_CDR\2311_12\codes_2311\a4_0_KG_classification_rainforest.m

% c.f. 1. E:\research\D_CDR\2311_12\d1_figS4_domain_RF_KG.m
%      2. E:\research\D_CDR\2311_12\d1_figS3_timing_1_ts.m

clear;
clc;

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

% land (area/weight) masks
load procData\area_lnd_weight.mat;
load procData\landmask_lnd.mat;
load procData\pftmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
landmask_lnd(:,1:33) = nan;
total_land_area = sum(area_gridbox.*landmask_lnd,"all",'omitnan')*1e6; % km^2 -> m^2
% get new area_lnd_weight
area_lnd = area_gridbox.*landmask_lnd*1e6;
area_lnd_weight = area_lnd./total_land_area;

% data attributes
lnd_info = ncinfo('E:\CESMoutput\lnd\Exp1\test.BSSP126cmip6_BPRP.clm2.h0.2015-01.nc');

% get original masks
% boreal/tropic masks: (1 tropical, 2 Arid, 3 Temperate, 4 Cold (Boreal), 5 Polar)
load procData_2311\KG_classes.mat;
mask_tropic = KG_classes == 1;
mask_dry = KG_classes == 2;
mask_temp = KG_classes == 3;
mask_boreal = KG_classes == 4;
KG_classes(KG_classes == 5) = nan;

% primary rainforest
load procData_2311\rainforest_mask.mat;
% 1: Congo, 2: SE Asia, 3: Amazon
rainforest_mask_logic = ~isnan(rainforest_mask);

% tropical: 23°26′
load E:\research\D_CDR\2309\procData\lon.mat;
load E:\research\D_CDR\2309\procData\lat.mat;
trop_lat_index = 72:121;
nontrop_lat_index = [1:71 122:192];

% get special masks
% 1. dry tropical (dry in tropical)
% 2. humid non-forest (non forest in tropical)

% 1. dry tropical (dry in tropical)
dry_in_trop = mask_dry;
dry_in_trop(:,nontrop_lat_index) = 0;

% 2. humid non-forest (non-forest in tropcial)
humid_non_forest = (mask_tropic - rainforest_mask_logic) == 1;

%% 1. get dry-tropical NBP
% c.f. E:\research\D_CDR\2311_12\d1_figS3_timing_1_ts.m

% yearly NBP
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);
NBP_cum = cumsum(NBP_all,3);

% area weight & NBP ts & cumulative NBP ts
area_weight_1 = (area_lnd.*dry_in_trop)./sum(area_lnd.*dry_in_trop,'all','omitnan');
NBP_ts_1 = nan(86,1);
for yy = 1:86
    NBP_ts_1(yy,1) = squeeze(sum(NBP_all(:,:,yy).*area_weight_1,'all','omitnan'));
end
cumNBP_ts_1 = cumsum(NBP_ts_1(:,1));

%% 2. humid non-rainforest (non-forest in tropcial)

% area weight & NBP ts & cumulative NBP ts
area_weight_2 = (area_lnd.*humid_non_forest)./sum(area_lnd.*humid_non_forest,'all','omitnan');
NBP_ts_2 = nan(86,1);
for yy = 1:86
    NBP_ts_2(yy,1) = squeeze(sum(NBP_all(:,:,yy).*area_weight_2,'all','omitnan'));
end
cumNBP_ts_2 = cumsum(NBP_ts_2(:,1));

%% 3. humid rainforest

% area weight & NBP ts & cumulative NBP ts
area_weight_3 = (area_lnd.*rainforest_mask_logic)./sum(area_lnd.*rainforest_mask_logic,'all','omitnan');
NBP_ts_3 = nan(86,1);
for yy = 1:86
    NBP_ts_3(yy,1) = squeeze(sum(NBP_all(:,:,yy).*area_weight_3,'all','omitnan'));
end
cumNBP_ts_3 = cumsum(NBP_ts_3(:,1));

%% visualization
% c.f. E:\research\D_CDR\2311_12\d1_figS3_timing_1_ts.m

color_here = [128,64,230; 26,166,64]/255;
LineWidth_here0 = 0.5;
LineWidth_here1 = 1;
FontSize_title = 11;
FontSize_axes = 9;

figure('Position',[10 10 1400 300]);
colororder(color_here);

a1 = subplot(1,3,1);
a1.LineWidth = LineWidth_here0;
a1.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(NBP_ts_1(:,1),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-15 7.5]);
yticks([-15 -10 -5 0 5]);
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
% ylabel({'Net biome productivity'; '(NBP, GtC/year)'})
ylabel({'NBP (GtC/year)'});
a1.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); cumNBP_ts_1(10:end,1) - cumNBP_ts_1(9,1)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-10 5]);
yticks([-10 -5 0])
% ylabel({'Cumulative carbon exchange (GtC)'})
a1.YGrid = 'on';
% title
tt = title('A Arid tropical','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% text(11,-456,'Abrupt reduction in CO_2 level in 2024','FontSize',10)

a2 = subplot(1,3,2);
a2.LineWidth = LineWidth_here0;
a2.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(NBP_ts_2(:,1),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-30 15]);
yticks([-30 -20 -10 0 10])
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
% ylabel({'Net biome productivity (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); cumNBP_ts_2(10:end,1) - cumNBP_ts_2(9,1)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-100 50]);
yticks([-100 -50 0])
a2.YGrid = 'on';
ylabel({'Cumulative NBP';'(GtC)'})
% title
tt = title('B Non-rainforest in humid tropcial','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a2 = subplot(1,3,3);
a2.LineWidth = LineWidth_here0;
a2.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(NBP_ts_3(:,1),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-60 30]);
yticks([-60 -40 -20 0 20])
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
% ylabel({'Net biome productivity (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); cumNBP_ts_3(10:end,1) - cumNBP_ts_3(9,1)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-500 250]);
yticks([-500 -250 0])
a2.YGrid = 'on';
ylabel({'Cumulative NBP';'(GtC)'})
% title
tt = title('C Rainforest in humid tropcial','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';



