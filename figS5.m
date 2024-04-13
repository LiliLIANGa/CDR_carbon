% Here draws the domain of different masks.

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

%% get data
% boreal/tropic masks: (1 tropical, 2 Arid, 3 Temperate, 4 Cold (Boreal), 5 Polar)

load procData_2311\KG_classes.mat;
mask_tropic = KG_classes == 1;
mask_boreal = KG_classes == 4;
KG_classes(KG_classes == 5) = nan;

load('colorData.mat','Paired12');
% mycolor = my_color(Paired12(2:9,:),160);
% mycolor = Paired12([4 7 3 9],:);
mycolor = Paired12([9 7 3 4],:);
mycolor(2,:) = [0.8 0.8 0.8];

load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

map_pcolorm = KG_classes;
map_temp = map_pcolorm;
map_pcolorm(1:144,:) = map_temp(145:288,:);
map_pcolorm(145:288,:) = map_temp(1:144,:);

%% get data 2

load procData_2311\rainforest_mask.mat;
map_pcolorm2 = rainforest_mask;
map_temp = map_pcolorm2;
map_pcolorm2(map_temp == 1) = 2;
map_pcolorm2(map_temp == 2) = 3;
map_pcolorm2(map_temp == 3) = 1;
map_temp = map_pcolorm2;
map_pcolorm2(1:144,:) = map_temp(145:288,:);
map_pcolorm2(145:288,:) = map_temp(1:144,:);

%% visualization 1 KG

% get background
% ax1 = subplot(1,2,1);
figure("Position",[10 10 700 400])
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
% ax1 = axes;
ax1 = worldmap([-60 90],[-180,180]);
% set(ax1, 'Position', [0,0.1,0.5,0.8])
setm(ax1,'MapProjection','Robinson');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor',[1 1 1]);
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm');
% h4 = scatterm(lat_s(sig_loose_IR),lon_s(sig_loose_IR),25,'Marker','.', ...
%     'MarkerEdgeColor',[0.3 0.3 0.3]);
% hold off;
% colorbar
colormap(mycolor);
caxis([0.5 4.5]);
colo = colorbar('southoutside');
colo.Ticks = 1:1:4;
colo.TickDirection = 'out';
colo.TickLabels = {'Tropical','Arid','Temperate','Boreal'};
set(colo, 'Position',[0.387,0.25,0.26,0.03], 'FontSize',10, 'TickDirection','out');
% set(get(colo, 'Label'), 'string', 'GtC/year',...
%     'FontSize',12,'HorizontalAlignment','center');
tt = title('A','FontSize',12);
tt.Units = 'Normalize';
tt.Position(1) = 0.2;
tt.Position(2) = 0.95;
tt.HorizontalAlignment = 'left';

%% visualization 2 RF

load('colorData.mat','Paired12');
mycolor = Paired12([2 5 11],:);
mycolor(1,:) = [0, 160, 62]/255;
mycolor(2,:) = [121, 189, 154]/255;
mycolor(3,:) = [161, 195, 35]/255;

% get background
% ax1 = subplot(1,2,1);
figure("Position",[10 10 700 400])
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
% ax1 = axes;
ax1 = worldmap([-60 90],[-180,180]);
% set(ax1, 'Position', [0,0.1,0.5,0.8])
setm(ax1,'MapProjection','Robinson');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor',[1 1 1]);
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm2');
% h4 = scatterm(lat_s(sig_loose_IR),lon_s(sig_loose_IR),25,'Marker','.', ...
%     'MarkerEdgeColor',[0.3 0.3 0.3]);
% hold off;
% colorbar
colormap(mycolor);
caxis([0.5 3.5]);
colo = colorbar('southoutside');
colo.Ticks = 1:1:3;
colo.TickDirection = 'out';
colo.TickLabels = {'Amazon','Congo','Southeast Asia'};
set(colo, 'Position',[0.387,0.25,0.26,0.03], 'FontSize',10, 'TickDirection','out');
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0.2;
tt.Position(2) = 0.95;
tt.HorizontalAlignment = 'left';


