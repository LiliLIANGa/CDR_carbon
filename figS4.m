% Here draws another part of figure 2 on the timing of some specific
% regions.

clear;
clc;

p = 'E:\research\D_CDR\2309\procData';
addpath(p);
clear p;

% load data
load procData\area_lnd_weight.mat;
load procData\landmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
landmask_lnd(:,1:33) = nan;
landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;

% time index
load procData\days_of_month.mat;
days_of_month_2015 = days_of_month(1:108,:);
days_of_month_2100 = days_of_month(109:end,:);
date_yy_all = unique(days_of_month(:,1),"rows");
date_yy_2015 = unique(days_of_month_2015(:,1),"rows");
date_yy_2100 = unique(days_of_month_2100(:,1),"rows");

% yearly NBP
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);
NBP_cum = cumsum(NBP_all,3);

load procData_2311\timing_index_GM.mat;
load procData_2311\timing_year_GM.mat;

%% get the divided regions
% regions of never, 2024-2026, and among 2027-2100.
% c.f. E:\research\D_CDR\2311_12\codes_2311\a4_1_KG_classification_rainforest.m

% get the masks: 
% 1. (b) Greenland (x)  index (lon_map, lat_map): [250:260] [176:180]  lon&lat: [311.25:323.75] [74.9215:78.6911]
% 2. (b) Canada         index (lon_map, lat_map): [212:222] [166:170]  lon&lat: [263.75:276.25] [65.4974:69.2670]
% 3. (c) Europe         index (lon_map, lat_map): [5:15] [143:147]  lon&lat: [5:17.5] [43.8220:47.5916]
% 4. (d) South China    index (lon_map, lat_map): [87:97] [122:126]  lon&lat: [107.5:120] [24.0314:27.8010]
% 5. (e) South America  index (lon_map, lat_map): [230:240] [90:94]  lon&lat: [286.25:298.75] [-6.1257:-2.3560]

m_all = nan(288,192,4);
% m_all(250:260,176:180,1) = 1;
m_all(212:222,166:170,1) = 1;
m_all(5:15,143:147,2) = 1;
m_all(87:97,122:126,3) = 1;
m_all(230:240,90:94,4) = 1;

% area_weight & NBP ts & cumulative NBP ts
m_all_weight = nan(288,192,4);
m_NBP_ts = nan(86,4);
m_cumNBP_ts = nan(86,4);
for mm = 1:4
    % area weight
    m_area_lnd = area_lnd.*m_all(:,:,mm);
    m_all_weight(:,:,mm) = m_area_lnd./sum(m_area_lnd,'all','omitnan');
    % NBP by mask
    m_NBP = NBP_all.*m_all(:,:,mm);
    % get the weighted ts (NBP and cumulative C)
    for yy = 1:86
        m_NBP_ts(yy,mm) = squeeze(sum(m_NBP(:,:,yy).*m_all_weight(:,:,mm),'all','omitnan'));
    end
    m_cumNBP_ts(:,mm) = cumsum(m_NBP_ts(:,mm));
end

% get timing for these regions
% c.f. E:\research\D_CDR\2311_12\d1_fig1_0_Global_timing.m
CalTime = m_NBP_ts(10:end,:);
timing_year = nan(4,1);
m_NBP_ttest = nan(77,4);
for mm = 2:4
    for i = 5:73
        window_mean = CalTime(i-4:i+4,mm);
        m_NBP_ttest(i,mm) = ttest(window_mean);
    end
    forlabel = double(m_NBP_ttest(5:73,mm) == 0);
    timing_year(mm,1) = find(forlabel,1) + 4 + 2023;
end

% timing_year =
%          NaN
%         2028
%         2035
%         2060

%% visualization 2. divided NBP
% c.f. E:\research\D_CDR\2311_12\codes_2311\a4_1_KG_classification_rainforest.m

color_here = [128,64,230; 26,166,64]/255;
LineWidth_here0 = 0.5;
LineWidth_here1 = 1;
FontSize_title = 11;
FontSize_axes = 9;

figure('Position',[10 10 800 400]);
colororder(color_here);

a1 = subplot(2,2,1);
a1.LineWidth = LineWidth_here0;
a1.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(m_NBP_ts(:,1),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-1 0.5]);
yticks([-1 -0.5 0 0.5]);
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
% ylabel({'Net biome productivity'; '(NBP, GtC/year)'})
ylabel({'NBP (GtC/year)'});
a1.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); m_cumNBP_ts(10:end,1) - m_cumNBP_ts(9,1)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-20 10]);
yticks([-20 -10 0])
% ylabel({'Cumulative carbon exchange (GtC)'})
a1.YGrid = 'on';
% title
tt = title('B Not found','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% text(11,-456,'Abrupt reduction in CO_2 level in 2024','FontSize',10)

a2 = subplot(2,2,2);
a2.LineWidth = LineWidth_here0;
a2.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(m_NBP_ts(:,2),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-30 15]);
yticks([-30 -15 0 15])
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
% ylabel({'Net biome productivity (GtC/year)'})
a2.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); m_cumNBP_ts(10:end,2) - m_cumNBP_ts(9,2)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-20 10]);
yticks([-20 -10 0])
a2.YGrid = 'on';
ylabel({'Cumulative NBP';'(GtC)'})
% title
tt = title('C \leq2028','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

a3 = subplot(2,2,3);
a3.LineWidth = LineWidth_here0;
a3.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(m_NBP_ts(:,3),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-30 15]);
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
yticks([-30 -15 0 15])
a3.YGrid = 'on';
ylabel({'NBP (GtC/year)'});
yyaxis right;
p2 = plot([nan(9,1); m_cumNBP_ts(10:end,3) - m_cumNBP_ts(9,3)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-400 200]);
yticks([-400 -200 0])
a3.YGrid = 'on';
% title
tt = title('D 2035 2060','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% tt = title('(a) Timing when NBP has no significant difference from zero','FontSize',12);
% tt.Units = 'Normalize';
% tt.Position(1) = 0.2;
% tt.Position(2) = 0.95;
% tt.HorizontalAlignment = 'left';


a4 = subplot(2,2,4);
a4.LineWidth = LineWidth_here0;
a4.FontSize = FontSize_axes;
p0 = line([9.5 9.5],[-100 500],'Color',[0.8 0.8 0.8],'LineWidth',2);
p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',LineWidth_here1);
hold on;
p1 = plot(m_NBP_ts(:,4),'LineWidth',LineWidth_here1);
xlim([1 86]);
ylim([-60 30]);
xticks([1 10 16:10:86]);
% xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
xticklabels({'2015','2024','','2040','','2060','','2080','','2100'});
yticks([-60 -30 0 30])
% ylabel({'Net biome productivity (GtC/year)'})
a4.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); m_cumNBP_ts(10:end,4) - m_cumNBP_ts(9,4)],'LineWidth',LineWidth_here1);
hold off;
box off;
ylim([-600 300]);
yticks([-600 -300 0])
ylabel({'Cumulative NBP';'(GtC)'})
a4.YGrid = 'on';
% title
tt = title('E 2060','FontSize',FontSize_title);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

