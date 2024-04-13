% Here merges orignial figure 2 of timing and fig. 3 of 

% Here draws the figure based on modified definition, give samples of some
% points (small area) instead of the whole patch.
% c.f. E:\research\D_CDR\2311_12\d1_fig2_timing_normal.m

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
NBP_cum_2100 = cumsum(NBP_2100_y,3);
clear NBP_2015_y NBP_2100_y;

load procData_2311\timing_index_GM.mat;
load procData_2311\timing_year_GM.mat;

% Brief summary:
% timing_index = 0: NBP being 0 throughout the data period
% timing_index = 99: NBP never reach C neutrality throughout the data period

%% visualization 1. timing map

% turn the ZeroIndex into actual years when they reach equilibrium
% 0 mask; 99 mask

timing_year_map = timing_year_GM;
timing_year_map(timing_year_map == 2023) = nan;
timing_year_map(timing_year_map == 2028) = nan;
timing_year_map(timing_year_map == 2122) = nan;
map_pcolorm = log10(timing_year_map - 2023);    % *********** NEW COLOR BAR *********
map_pcolorm_temp = map_pcolorm;
map_pcolorm(1:144,:) = map_pcolorm_temp(145:288,:);
map_pcolorm(145:288,:) = map_pcolorm_temp(1:144,:);

timing_temp = timing_year_GM == 2023 | timing_year_GM == 2028;
map_pcolorm_2428 = double(timing_temp);
map_pcolorm_2428(map_pcolorm_2428 == 0) = nan;
map_pcolorm_temp = map_pcolorm_2428;
map_pcolorm_2428(1:144,:) = map_pcolorm_temp(145:288,:);
map_pcolorm_2428(145:288,:) = map_pcolorm_temp(1:144,:);

map_pcolorm_never = double(timing_year_GM == (99 + 2023));
map_pcolorm_never(map_pcolorm_never == 0) = nan;
map_pcolorm_temp = map_pcolorm_never;
map_pcolorm_never(1:144,:) = map_pcolorm_temp(145:288,:);
map_pcolorm_never(145:288,:) = map_pcolorm_temp(1:144,:);

% colorbar
load('colorData.mat','BuPu9');
mycolor = my_color(BuPu9(4:end,:),100);
mycolor1 = BuPu9(1,:);
mycolor3 = [0.2 0.2 0.2];

% coastal
load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

%%

figure('Position',[10,10,830,470]);

% get background
ax1 = axes;
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
worldmap([-60 90],[-180,180]);
% ax = worldmap([-60,90],[0,360]);
set(ax1, 'Position', [0,0.1,1,0.7])
setm(ax1,'MapProjection','eqdcylin');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off','Color',[0.7 0.7 0.7]);
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
fm.FaceColor = [250,250,250]/255;
fm.EdgeColor = 'none';
set(fm, 'linewidth',0.1, 'Visible','on')
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm');
% colorbar
colormap(ax1,mycolor);
caxis(log10([2029 2098]-2023));           % *********** NEW COLOR BAR *********
colo = colorbar('east');
colo.Ticks = log10([2029 2030 2040 2050 2060 2070 2080 2090 2096]-2023);         % *********** NEW COLOR BAR *********
colo.TickDirection = 'out';
% colo.TickLabels = {'2027','2030','2040','2050','2060','2070','2080','','2098'};
% \leq2026
colo.TickLabels = {'','2030','2040','2050','2060','2070','2080','','2096'};
% set(colo, 'Position',[0.4,0.1,0.36,0.032], 'FontSize',10, 'TickDirection','out');
set(colo, 'Position',[0.1843,0.2415,0.0132,0.3192], 'FontSize',10, 'TickDirection','out');
% set(get(colo, 'Label'), 'string', 'GtC/year',...
%     'FontSize',12,'HorizontalAlignment','center');

% tt = title('A Timing when NBP has no significant difference with zero','FontSize',12);
% tt.Units = 'Normalize';
% tt.Position(1) = 0.2;
% tt.Position(2) = 0.95;
% tt.HorizontalAlignment = 'left';

% add another all_zero part
ax2 = axes;
worldmap([-60 90],[-180,180]);
set(ax2,'position',[0,0.1,1,0.7]);
setm(ax2,'MapProjection','eqdcylin');
set(ax2, 'Visible','off');
setm(ax2, 'ParallelLabel','off' ,'MeridianLabel','off');
box off
axis off
hidden off
fm = framem;
set(fm, 'Visible','off')
hold on;
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm_2428');
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor','none');
colormap(ax2,mycolor1);
colo = colorbar('east');
colo.Ticks = 1;
colo.TickLength = 0.15;
colo.TickLabels = {'\leq2028'};
set(colo, 'Position',[0.1843,0.2041,0.0132,0.0255], 'FontSize',10, 'TickDirection','out');

% add another never balance part
ax3 = axes;
worldmap([-60 90],[-180,180]);
set(ax3,'position',[0,0.1,1,0.7]);
setm(ax3,'MapProjection','eqdcylin');
set(ax3, 'Visible','off');
setm(ax3, 'ParallelLabel','off' ,'MeridianLabel','off');
box off
axis off
hidden off
fm = framem;
set(fm, 'Visible','off')
hold on;
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm_never');
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor','none');

% outline the tropical region
linWid = 0.7;
% h_box2 = linem([-15 -15 15 15 -15],[0 270 270 0 0],'color','k','linewi',1);
h_box2 = plotm([-15 15],[155 155],'color','k','linewi',linWid);
h_box2 = plotm([-15 15],[270 270],'color','k','linewi',linWid);
h_box2 = plotm([-15 -15],[155 0],'color','k','linewi',linWid);
h_box2 = plotm([-15 -15],[0 270],'color','k','linewi',linWid);
h_box2 = plotm([15 15],[155 0],'color','k','linewi',linWid);
h_box2 = plotm([15 15],[0 270],'color','k','linewi',linWid);
% outline the boreal region
h_box2 = plotm([50 80],[175 175],'color','k','linewi',linWid);
h_box2 = plotm([50 80],[200 200],'color','k','linewi',linWid);
h_box2 = plotm([50 50],[175 0],'color','k','linewi',linWid);
h_box2 = plotm([50 50],[0 200],'color','k','linewi',linWid);
h_box2 = plotm([80 80],[175 0],'color','k','linewi',linWid);
h_box2 = plotm([80 80],[0 200],'color','k','linewi',linWid);

colormap(ax3,[0.8 0.8 0.8]);
colo = colorbar('west');
colo.Ticks = 1;
colo.TickLength = 0.15;
colo.TickLabels = {'Not found'};
set(colo, 'Position',[0.1843,0.1701,0.0132,0.0255], 'FontSize',10, 'TickDirection','out');


%% boxes

% % tropical
% h_box2 = linem([-23 -23 23 23 -23],[3 330 330 3 3],'color','k','linewi',1);
% h_box2 = plotm([-23 -23],[3 179.99],'color','k','linewi',1);
% h_box2 = plotm([-23 -23],[180.01 330],'color','k','linewi',1);
% h_box2 = plotm([23 23],[3 179.99],'color','k','linewi',1);
% h_box2 = plotm([23 23],[180.01 330],'color','k','linewi',1);

% % boxes of other samples
% % 1. Greenland      index (lon_map, lat_map): [250:260] [176:180]  lon&lat: [311.25:323.75] [74.9215:78.6911]
% % 2. Canada         index (lon_map, lat_map): [212:222] [166:170]  lon&lat: [263.75:276.25] [65.4974:69.2670]
% % 3. Europe         index (lon_map, lat_map): [5:15] [143:147]  lon&lat: [5:17.5] [43.8220:47.5916]
% % 4. South China    index (lon_map, lat_map): [87:97] [122:126]  lon&lat: [107.5:120] [24.0314:27.8010]
% % 5. South America  index (lon_map, lat_map): [230:240] [90:94]  lon&lat: [286.25:298.75] [-6.1257:-2.3560]
% % h_box1 = linem([74.92 74.92 78.69 78.69 74.92],[311.25 323.75 323.75 311.25 311.25],'color','k','linewi',1);
% h_box2 = linem([65.47 69.26 69.26 65.47 65.47],[263.75 263.75 276.25 276.25 263.75],'color','k','linewi',1);
% h_box3 = linem([43.82 43.82 47.59 47.59 43.82],[5 17.5 17.5 5 5],'color','k','linewi',1);
% h_box4 = linem([24.03 24.03 27.8 27.8 24.03],[107.5 120 120 107.5 107.5],'color','k','linewi',1);
% h_box5 = linem([-6.12 -6.12 -2.35 -2.35 -6.12],[286.25 298.75 298.75 286.25 286.25],'color','w','linewi',1);


