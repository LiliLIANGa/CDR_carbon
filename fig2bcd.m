% Here shows the accumulative NBP in 2024-2100, and start comparing the tropical and boreal regions.

% c.f. E:\research\D_CDR\2311_12\codes_2311\a4_1_KG_classification_rainforest.m

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

% load main data of C fluxes
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);
% calculate the cumulative sum
NBP_cum = cumsum(NBP_all,3);
NBP_cum_2100 = cumsum(NBP_2100_y,3);
clear NBP_2015_y NBP_2100_y;

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

% get the NBP ts for different climate zones
NBP_KG_ts = nan(86,5);    % [years 2015-2100, climate zones 5]
NBP_cumulKG_ts = nan(86,5);
for i = 1:5
    % get the mask
    KG_mask = KG_classes == i;

    % get the area_weight
    KG_area_lnd = area_lnd.*KG_mask;
    KG_area_total = sum(KG_area_lnd,'all','omitnan');
    KG_area_weight = KG_area_lnd./KG_area_total;
    
    % get the weighted C flux & cumulative C
    for yy = 1:86
        NBP_KG_ts(yy,i) = squeeze(sum(NBP_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        NBP_cumulKG_ts(yy,i) = squeeze(sum(NBP_cum(:,:,yy).*KG_area_weight,'all','omitnan'));
    end
end
NBP_cumulKG_2100_ts = NBP_cumulKG_ts(10:end,:) - NBP_cumulKG_ts(9,:);

%% added on 2024/4/10 see the timing different regions reach their 'equilibrium'
% 1: tropical: 1:3          2040    2039
% 2: Arid: 4:7              2028    2030
% 3: Temperate: 8:16        2029    2041
% 4: Cold: 17:28 (Boreal)   2030    2028

NBP_KG_ts_for_timing = NBP_KG_ts(10:end,:);
for re = 1:4
    % pass
    NBP_2100_ts_9y_ttest = nan(77,1);
    for i = 5:73
        window_mean = NBP_KG_ts_for_timing(i-4:i+4,re);
        NBP_2100_ts_9y_ttest(i,1) = ttest(window_mean);
    end
    % get the timing (index and actual year)
    forlabel = double(NBP_2100_ts_9y_ttest(5:73,1) == 0);
    disp(re)
    timing_index = find(forlabel,1)
    timing_year = timing_index + 4 + 2023
end

%% visualization 0. (color)

load('colorData.mat','PRGn10');
mycolor = my_color(PRGn10(2:9,:),160);
mycolor(77:84,:) = [];
color_here = [128,64,230; 26,166,64; 163, 194, 255; 150, 150, 150; 230,128,0]/255;


%% visualization 1. (regions ts)
% c.f. E:\research\D_CDR\2311\a2_2_class_PFTs_ts.m

LineWidth_here0 = 0.8;
LineWidth_here1 = 1;

figure('Position',[10 10 830 300]);
colororder(color_here);

a1 = subplot(1,2,1);
a1.LineWidth = LineWidth_here0;
p0 = line([9.5 9.5],[-50 50],'Color',[0.7 0.7 0.7],'LineWidth',3);
hold on;
p1 = plot(NBP_KG_ts(:,[1 4 3 2]));
p1(1).LineWidth = 1;
p1(2).LineWidth = 1;
p1(3).LineWidth = 0.8;
p1(4).LineWidth = 0.8;
hold off;
xlim([1 86]);
ylim([-40 20]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
% ylabel({'Net biome productivity';'(GtC/year)'})
ylabel({'NBP (GtC/year)'});
a1.YGrid = 'on';
% title
tt = title('A Time when NBP reaches equilibrium','FontSize',12);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% legend
% 1: tropical: 1:3
% 2: Arid: 4:7
% 3: Temperate: 8:16
% 4: Cold: 17:28 (Boreal)
% 5: Polar: 29:30
l = legend([p1(1),p1(2),p1(3),p1(4)],'Tropical','Boreal','Temperate','Arid');
l.Box = 'off';
l.Location = 'southeast';
l.FontSize = 11;
text(11,-37,'CO_2 removal in 2024','FontSize',11)

a2 = subplot(1,2,2);
a2.LineWidth = LineWidth_here0;
% p0 = line([9.5 9.5],[-200 200],'Color',[0.7 0.7 0.7],'LineWidth',3);
% p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(NBP_cumulKG_ts(10:end,[1 4 3 2]) - NBP_cumulKG_ts(9,[1 4 3 2]),'LineWidth',1);
p1(1).LineWidth = 1;
p1(2).LineWidth = 1;
p1(3).LineWidth = 0.8;
p1(4).LineWidth = 0.8;
hold off
xlim([1 77]);
ylim([-200 100]);
xticks([1 7 17:10:77]);
xticklabels({'2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Cumulative NBP (GtC)'})
a2.YGrid = 'on';
% title
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0.3;
tt.HorizontalAlignment = 'left';
% legend
% 1: bare ground; 2: tropical index; 3: temperate index; 4: boreal index
% l = legend(p1,'Bare ground','tropical','temperate','boreal');
% l.Box = 'off';
% l.Location = 'northeast';
% l.FontSize = 12;
% text(11,-77,'CO_2 concentration abrupt decrease in 2024')

%% visualization 2. (map)
% c.f. E:\research\D_CDR\2311_12\codes_2311\a3_cumul_grid.m

map_pcolorm = NBP_cum_2100(:,:,77);
map_temp = map_pcolorm;
map_pcolorm(1:144,:) = map_temp(145:288,:);
map_pcolorm(145:288,:) = map_temp(1:144,:);

load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

figure('Position',[10,10,830,470]);
% get background
ax1 = axes;
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
worldmap([-60 90],[-180,180]);
% ax = worldmap([-60,90],[0,360]);
set(ax1, 'Position', [0,0.1,1,0.7])
% set(ax1, 'Position', [0,0.129,0.3347,0.796])
setm(ax1,'MapProjection','eqdcylin');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
fm.FaceColor = [250,250,250]/255;
% fm.FaceAlpha = 0.3;
fm.EdgeColor = 'none';
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm');
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor','none');

% colorbar
colormap(my_color(mycolor,100));
caxis([-600 600]);
colo = colorbar('east');
colo.Ticks = [-600:200:600];
colo.TickDirection = 'out';
colo.TickLabels = {'\leq-600','-400','-200','0','200','400','\geq600'};
set(colo, 'Position',[0.1843,0.2,0.0132,0.3192], 'FontSize',10, 'TickDirection','out');
set(get(colo, 'Label'), 'string', '(GtC)',...
    'FontSize',11,'HorizontalAlignment','left');

