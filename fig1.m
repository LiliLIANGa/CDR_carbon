

%% 1. (ts CO2 NBP) data preparation 

% 1. NBP changes -> show the confidence level (0.95) significant level (0.05)
% 2. CO2 sudden drop from a near-present level to pi-level
% 3. the equevalent amount of ppm of atm. CO2 concentrations
% 3.5 the relative conctribution

clear;
clc;

p = 'E:\research\D_CDR\2309\procData';
addpath(p);
clear p;

load procData\days_of_month.mat;
days_of_month_2015 = days_of_month(1:108,:);
days_of_month_2100 = days_of_month(109:end,:);
date_yy_all = unique(days_of_month(:,1),"rows");
date_yy_2015 = unique(days_of_month_2015(:,1),"rows");
date_yy_2100 = unique(days_of_month_2100(:,1),"rows");

% CO2 data
load procData_2311\CO2_2015_ts_y.mat;
load procData_2311\CO2_2100_ts_y.mat;
CO2_all = [CO2_2015_ts_y; CO2_2100_ts_y];

% NBP data
load procData_2311\NBP_2015_ts_y.mat;
load procData_2311\NBP_2100_ts_y.mat;
% accumulative
NBP_2015_accum_y = cumsum(NBP_2015_ts_y);
NBP_2100_accum_y = cumsum(NBP_2100_ts_y);

% NBP (cumulative, GtC) ---> CO2 (ppm)
% unit transfer: GtC -> ppm
% 1 ppm atmospheric CO2 ∼ 2.12 GtC
% 1 GtC ~ 0.4717 ppm CO2 change
NBP_2015_accum_ppm_y = -cumsum(NBP_2015_ts_y*0.4717);
NBP_2100_accum_ppm_y = -cumsum(NBP_2100_ts_y*0.4717);
% modified at Dec 13
NBP_all_ts_y = [NBP_2015_ts_y; NBP_2100_ts_y];
NBP_all_accum_ppm_y = -cumsum(NBP_all_ts_y*0.4717);

%% 2. (NBP lat and map)
% c.f. E:\research\D_CDR\2311_12\codes_2311\a1_2_initial_mean_map_lati.m

% MEAN MAP
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;

load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

% NBP in till 2040 -> from a1_1_initial_overallTiming.m
% NBP in last ten years -> average are zero
NBP_IRmean = mean(NBP_2100_y(:,:,1:15),3,'omitnan');
NBP_LRmean = mean(NBP_2100_y(:,:,67:77),3,'omitnan');

% significance
NBP_IRmean_sig = nan(288,192);
NBP_LRmean_sig = nan(288,192);
for i = 1:288
    for j = 33:192
        NBP_IRmean_sig(i,j) = ttest(squeeze(NBP_2100_y(i,j,1:15)));
        NBP_LRmean_sig(i,j) = ttest(squeeze(NBP_2100_y(i,j,67:77)));
    end
end
NBP_IRmean_sig = double(NBP_IRmean_sig);
NBP_LRmean_sig = double(NBP_LRmean_sig);
NBP_IRmean_sig(NBP_IRmean_sig == 0) = nan;
NBP_LRmean_sig(NBP_LRmean_sig == 0) = nan;

% stipple (significance)
sig_loose_IR = nan(48,32);     % 288/6 192/6
sig_loose_LR = nan(48,32);     % 288/6 192/6
[lat_s,lon_s]=meshgrid(lat(1:6:192,1),lon(1:6:288,1));
P_sig_inff1 = double(NBP_IRmean_sig);
P_sig_inff2 = double(NBP_LRmean_sig);
aa = 0;
bb = 0;
for k = 1:6:288
    aa = aa+1;
    for j = 1:6:192
        bb = bb+1;
        sig_loose_IR(aa,bb) = P_sig_inff1(k,j);
        sig_loose_LR(aa,bb) = P_sig_inff2(k,j);
    end
    bb = 0;
end
sig_loose_IR(isnan(sig_loose_IR)) = 0;
sig_loose_IR = logical(sig_loose_IR);
sig_loose_LR(isnan(sig_loose_LR)) = 0;
sig_loose_LR = logical(sig_loose_LR);

%% latitudinal

load procData\area_lnd_weight.mat;
load procData\landmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
landmask_lnd(:,1:33) = nan;
landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;
lat_bin = [34:1:190]';
lat_flux = nan(924,161);      % the order follows 'lat_bin'
for bb = 1:161
    % get the lat index
    lat_index = bb+29;
    % get the area_weight
    lat_area_lnd = area_lnd(:,lat_index);
    lat_area_total = sum(lat_area_lnd,'all','omitnan');
    lat_area_weight = lat_area_lnd./lat_area_total;
    % get the weighted C flux
    for yy = 1:86
        if yy <= 9
            lat_flux(yy,bb) = squeeze(sum(NBP_2015_y(:,lat_index,yy).*lat_area_weight,'all','omitnan'));
        else
            lat_flux(yy,bb) = squeeze(sum(NBP_2100_y(:,lat_index,yy-9).*lat_area_weight,'all','omitnan'));
        end
    end
end
lat_flux_show = flipud(lat_flux');
% get the specific latitudes (lat_map loaded from the below)
lat_show = nan(161,1);
for bb = 1:161
    % get the lat index (not really used)
    lat_index = bb+29;
    lat_show(bb,1) = mean(lat_map(lat_index,1),'all','omitnan');
end

%% visualization 0. (color)

% Purple, Green, Orange
% "#8040E6";"#1AA640";"#E68000"
% [128,64,230; 26,166,64; 230,128,0]

% Light Green, Gray,        Pink blue,     Purple,     Pink orange, Dark black
% [34 200 0;   170 170 170; 163 194 255;   154 99 235; 244 177 131; 20 20 20]/255;

load('colorData.mat','PRGn10');
mycolor = my_color(PRGn10(2:9,:),160);
mycolor(77:84,:) = [];

color_here = [128,64,230; 26,166,64]/255;

%% visualization 1. (ts CO2 NBP lat)
% c.f. 1. E:\research\D_CDR\2311_12\codes_2311\a1_1_initial_ts_z.m
%      2. E:\research\D_CDR\2311_12\codes_2311\a1_2_initial_mean_map_lati.m

figure('Position',[10 10 1600 300]);
a1 = subplot(1,3,1);
colororder(a1,color_here);
p0 = line([9.5 9.5],[-10 10],'Color',[0.7 0.7 0.7],'LineWidth',3);
p00 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot([NBP_2015_ts_y; NBP_2100_ts_y],'LineWidth',1);
ar1 = area(a1,[9+14.5 89],[-10 -10]);
ar1.FaceColor = [180,180,180]/255;
ar1.FaceAlpha = 0.1;
ar1.EdgeColor = 'none';
ar2 = area(a1,[9+14.5 89],[5 5]);
ar2.FaceColor = [180,180,180]/255;
ar2.FaceAlpha = 0.1;
ar2.EdgeColor = 'none';
hold off
xlim([1 86]);
ylim([-10 5]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Net biome productivity (NBP)';'(GtC/year)'});
text(25,-2.8,{'No significant difference from';'zero starting 2038'},'FontSize',11,'Color',[0.1 0.1 0.1])
a1.YGrid = 'on';
yyaxis right;
p2 = plot([nan(9,1); NBP_2100_accum_y],'LineWidth',1);
box off;
ylim([-50 25]);
yticks([-40 -20 0])
ylabel({'Cumulative NBP (GtC)'})
a1.YGrid = 'on';
% title
tt = title('A','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% legend
% l = legend(p1,'CO_2 concentration');
% l.Box = 'off';
% l.Location = 'southeast';

a2 = subplot(1,3,2);
colororder(a2,color_here);
p0 = line([9.5 9.5],[-30 30],'Color',[0.7 0.7 0.7],'LineWidth',3);
p00 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot([nan(9,1); NBP_2100_accum_ppm_y],'LineWidth',1);
ar1 = area(a2,[9+14.5 89],[-40 -40]);
ar1.FaceColor = [188,188,188]/255;       % pro color: [135,74,231]/255
ar1.FaceAlpha = 0.1;
ar1.EdgeColor = 'none';
ar2 = area(a2,[9+14.5 89],[40 40]);
ar2.FaceColor = [180,180,180]/255;
ar2.FaceAlpha = 0.1;
ar2.EdgeColor = 'none';
hold off
xlim([10 86]);
ylim([0 40]);
xticks([1 10 16:10:86]);
yticks([0 10 20 30 40]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Cumulative NBP equivalent to'; 'CO_2 concentration (ppm)'})
yyaxis right;
hold on;
p2 = plot([nan(9,1); CO2_2100_ts_y],'LineWidth',1);
box off;
ylim([280 320]);
yticks(280:10:320)
ylabel({'Atmospheric CO_2 concentration (ppm)'})
a2.YGrid = 'on';
text(11,284,'CO_2 removal in 2024','FontSize',11)
% title
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';
% legend
% l = legend(p1,'CO_2 concentration');
% l.Box = 'off';
% l.Location = 'southeast';

a3 = subplot(1,3,3);
imagesc(lat_flux_show);
colormap(my_color(mycolor,100));
caxis([-20 20])
xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
yticks(fliplr(161 - [3 35 68 99 131 160]))
yticklabels({'90°','60°N','30°N','0°','30°S','60°S'});
ylabel({'NBP (GtC/year)'});
% cl = colorbar;
% cl.Label.String = {'Net biome productivity (NBP)';'(GtC/year)'};
% cl.Label.FontSize = 11;
% title
tt = title('C','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

%% visualization 2. (map)
% c.f. E:\research\D_CDR\2311_12\codes_2311\a1_2_initial_mean_map_lati.m
% new projection: 

map_pcolorm1 = NBP_IRmean;
map_pcolorm2 = NBP_LRmean;
% modify the longitude
map_pcolorm1(1:144,:) = NBP_IRmean(145:288,:);
map_pcolorm1(145:288,:) = NBP_IRmean(1:144,:);
map_pcolorm2(1:144,:) = NBP_LRmean(145:288,:);
map_pcolorm2(145:288,:) = NBP_LRmean(1:144,:);

figure('Position',[10,10,1600,390]);

% get background
ax1 = subplot(1,2,1);
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
worldmap([-60 90],[-180,180]);
% ax = worldmap([-60,90],[0,360]);
set(ax1, 'Position', [0,0.05,0.5,0.8])
setm(ax1,'MapProjection','eqdcylin');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
fm.FaceColor = [250,250,250]/255;
% fm.FaceColor = [210,224,250]/255;
% fm.FaceColor = [0.8 0.8 0.8];
fm.FaceAlpha = 0.3;
fm.EdgeColor = 'none';
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm1');
h4 = scatterm(lat_s(sig_loose_IR),lon_s(sig_loose_IR),25,'Marker','.', ...
    'MarkerEdgeColor',[0.3 0.3 0.3]);
h2 = patchm(coastlat,coastlon,'EdgeColor',[.7 .7 .7],'FaceColor','none','LineWidth',0.7);
% hold off;

% colorbar
% revised at April 1st
colormap(my_color(mycolor,100));
caxis([-20 20]);
colo = colorbar('east');
colo.Ticks = -20:10:20;
colo.TickLabels = {'\leq-20','-10','0','10','\geq20'};
set(colo, 'Position',[0.09,0.16,0.0082,0.4003], 'FontSize',10, 'TickDirection','out');
set(get(colo, 'Label'), 'string', 'GtC/year',...
    'FontSize',12,'HorizontalAlignment','center');

tt = title('D NBP average during 2024-2038','FontSize',12);
tt.Units = 'Normalize';
% tt.Position(1) = 0.2;
tt.Position(2) = 1.05;
tt.HorizontalAlignment = 'right';

% get background
ax2 = subplot(1,2,2);
hold on;
% axesm("MapProjection",'mercator','MapLatLimit',[-60 90])
worldmap([-60 90],[-180,180]);
% ax2 = worldmap([-60,90],[0,360]);
set(ax2, 'Position', [0.5 0.05 0.5 0.8]);
setm(ax2,'MapProjection','eqdcylin'); %	eqdcylin
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax2, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
fm.FaceColor = [250,250,250]/255;
% fm.FaceColor = [243,248,255]/255;
% fm.FaceColor = [0.8 0.8 0.8];
fm.FaceAlpha = 0.3;
fm.EdgeColor = 'none';
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm2');
h4 = scatterm(lat_s(sig_loose_LR),lon_s(sig_loose_LR),25,'Marker','.', ...
    'MarkerEdgeColor',[0.3 0.3 0.3]);
h2 = patchm(coastlat,coastlon,'EdgeColor',[.7 .7 .7],'FaceColor','none','LineWidth',0.7);
hold off;
% colorbar
colormap(my_color(mycolor,100));
caxis([-20 20]);

% revised before
% colo = colorbar('eastoutside');
% colo.Ticks = -20:5:20;
% colo.TickLabels = {'\leq-20','-15','-10','-5','0','5','10','15','\geq20'};
% set(colo, 'Position',[0.92,0.19,0.01,0.66], 'FontSize',10, 'TickDirection','out');
% set(get(colo, 'Label'), 'string', 'GtC/year',...
%     'FontSize',12,'HorizontalAlignment','center');

% subtitle
tt = title('E NBP average during 2090-2100','FontSize',12);
tt.Units = 'Normalize';
% tt.Position(1) = 0.2;
tt.Position(2) = 1.05;
% tt.HorizontalAlignment = 'left';
tt.HorizontalAlignment = 'right';

