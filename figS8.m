% Here draws the figure of latitudinal temperature and precipitation
% and the domain for tropical, boreal, arid, and temperate regions.


clear;
clc;

p = 'E:\research\D_CDR\2309\procData';
addpath(p);
clear p;

% load data
load procData\area_lnd_weight.mat;
load procData\landmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2

% time index
load procData\days_of_month.mat;
days_of_month_2015 = days_of_month(1:108,:);
days_of_month_2100 = days_of_month(109:end,:);
date_yy_all = unique(days_of_month(:,1),"rows");
date_yy_2015 = unique(days_of_month_2015(:,1),"rows");
date_yy_2100 = unique(days_of_month_2100(:,1),"rows");

% data attributes
lnd_info = ncinfo('E:\CESMoutput\lnd\Exp1\test.BSSP126cmip6_BPRP.clm2.h0.2015-01.nc');

%% TASK 1 TSA
% c.f. E:\research\D_CDR\2311_12\codes_2311\a1_2_initial_mean_map_lati.m

% TSA
load procData_2311\TSA_2015_y.mat;
load procData_2311\TSA_2100_y.mat;
load procData\landmask_lnd.mat;

% calculation
landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;
lat_bin = [30:1:190]';
lat_data = nan(86,161);      % the order follows 'lat_bin'
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
            lat_data(yy,bb) = squeeze(sum(TSA_2015_y(:,lat_index,yy).*lat_area_weight,'all','omitnan'));
        else
            lat_data(yy,bb) = squeeze(sum(TSA_2100_y(:,lat_index,yy-9).*lat_area_weight,'all','omitnan'));
        end
    end
end

% get the temperature anomalies: minus the 2015-2040 average
load('E:\research\D_CDR\2311_12\procData_2311\TSA_2015_ts_y.mat')
for bb = 1:161
    lat_data(:,bb) = lat_data(:,bb) - mean(lat_data(1:9,bb));
end

%% TASK 2 TMQ
% c.f. E:\research\D_CDR\2311_12\codes_2311\a1_2_initial_mean_map_lati.m

% TSA
load procData_2311\TMQ_2015_y.mat;
load procData_2311\TMQ_2100_y.mat;
load procData\landmask_lnd.mat;

% calculation
landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;
lat_bin = [30:1:190]';
lat_data = nan(86,161);      % the order follows 'lat_bin'
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
            lat_data(yy,bb) = squeeze(sum(TMQ_2015_y(:,lat_index,yy).*lat_area_weight,'all','omitnan'));
        else
            lat_data(yy,bb) = squeeze(sum(TMQ_2100_y(:,lat_index,yy-9).*lat_area_weight,'all','omitnan'));
        end
    end
end

% get the temperature anomalies: minus the 2015-2040 average
% load('E:\research\D_CDR\2311_12\procData_2311\TMQ_2015_ts_y.mat')
for bb = 1:161
    lat_data(:,bb) = lat_data(:,bb) - mean(lat_data(1:9,bb));
end

%% visualization

load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

% load('colorData.mat','PRGn10');
% mycolor = my_color(PRGn10(2:9,:),160);
% mycolor(77:84,:) = [];
load('colorData.mat','RdBu4');
mycolor = my_color(RdBu4,160);
mycolor(77:84,:) = [];
mycolor = my_color(RdBu4,160);
mycolor = mycolor(41:160,:);
mycolor = flipud(mycolor);

lat_flux_show = flipud(lat_data');

% get the specific latitudes (lat_map loaded from the below)
lat_show = nan(161,1);
for bb = 1:161
    % get the lat index
    lat_index = bb+29;
    lat_show(bb,1) = mean(lat_map(lat_index,1),'all','omitnan');
end

figure('Position',[10,10,980,360]);
ax1 = subplot(1,2,1);
set(ax1,'FontSize',11);
imagesc(lat_flux_show);
colormap(my_color(mycolor,100));
caxis([-4 2])

xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});

yticks(fliplr(161 - [3 35 68 99 131]))
yticklabels({'60°N','30°N','0°','30°S','60°S'})

cl = colorbar;
cl.Label.String = {'Temperature anomalies (^{o}C)';'relative to 2015-2024 average'};
cl.Label.FontSize = 11;

% title
tt = title('A','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';


% %% *************************** visualization *************************** 
% TMQ (Total (vertically integrated) precipitation water), kg/m2

load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

% load('colorData.mat','PRGn10');
% mycolor = my_color(PRGn10(2:9,:),160);
% mycolor(77:84,:) = [];
load('colorData.mat','RdBu4');
mycolor = my_color(RdBu4,160);
mycolor = mycolor(41:160,:);
mycolor = flipud(mycolor);

lat_flux_show = flipud(lat_data');

% get the specific latitudes (lat_map loaded from the below)
lat_show = nan(161,1);
for bb = 1:161
    % get the lat index
    lat_index = bb+29;
    lat_show(bb,1) = mean(lat_map(lat_index,1),'all','omitnan');
end

% figure('Position',[10,10,500,360]);
ax2 = subplot(1,2,2);
set(ax2,'FontSize',11);
imagesc(lat_flux_show);
colormap(my_color(mycolor,100));
caxis([-4 2])

xlim([1 86]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});

yticks(fliplr(161 - [3 35 68 99 131]))
yticklabels({'60°N','30°N','0°','30°S','60°S'})

cl = colorbar;
cl.Label.String = {'Precipitation anomalies (kg/m^2)';'relative to 2015-2024 average'};
cl.Label.FontSize = 11;

% title
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';


