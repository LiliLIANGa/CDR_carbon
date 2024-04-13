% Here we get NBP for each dominant PFT, which is also obtained from this
% code.

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

load procData\pftmask_lnd.mat;
pftmask_lnd(pftmask_lnd == 0) = nan;

nc_filepath = 'E:\CESMinputData_ssp126\cam\clm\landuse.timeseries_0.9x1.25_SSP1-2.6_78pfts_CMIP6_simyr1850-2100_c190214.nc';
nc_info = ncinfo(nc_filepath);

% PCT_NAT_PFT
% [lsmlon, lsmlat, natpft, time]  [188 192 15 251]
PCT_NAT_PFT = ncread(nc_filepath,'PCT_NAT_PFT');
PCT_NAT_PFT = mean(PCT_NAT_PFT(:,:,:,166:251),4,'omitnan');       % 2015.12 - 2100.12

%% Part 1
%% get the dominant PFT for each grid

PFT_domi = nan(288,192);
for i = 1:288
    for j = 1:192
        pft_frac = squeeze(PCT_NAT_PFT(i,j,:));
        PFT_domi(i,j) = find(pft_frac == max(pft_frac));
    end
end
PFT_domi = PFT_domi.*pftmask_lnd;

save procData_2311\PFT_domi.mat PFT_domi;

%% visualization (PFTs)

load procData_2311\PFT_domi.mat;
load coastlines;
load('E:\research\D_CDR\2309\procData\lat.mat')
load('E:\research\D_CDR\2309\procData\lon.mat')
lat_map = lat;
lon_map = lon;

load('colorData.mat','Accent8');
load('colorData.mat','Cat_12');
load('colorData.mat','Paired12');
mycolor = my_color([Cat_12;Accent8(3,:)],15);
mycolor(15,:) = Accent8(1,:);
mycolor(1,:) = [0.85 0.85 0.85];

map_pcolorm = PFT_domi;
map_pcolorm_temp = map_pcolorm;
map_pcolorm(1:144,:) = map_pcolorm_temp(145:288,:);
map_pcolorm(145:288,:) = map_pcolorm_temp(1:144,:);

figure('Position',[10,10,900,450]);
% get background
ax1 = axes;
hold on
% axesm('MapProjection','mercator','MapLatLimit',[-60 90]);
worldmap([-60 90],[-180 180]);
% ax = worldmap([-60,90],[0,360]);
set(ax1, 'Position', [0,0.1,1,0.7])
setm(ax1,'MapProjection','Robinson');
% setm(ax,'MeridianLabel','on','MLabelParallel','south','MLineLocation',60);
set(gca, 'Visible','off');
setm(ax1, 'ParallelLabel','off' ,'MeridianLabel','off');
fm = framem;
set(fm, 'linewidth',1, 'Visible','on')
% draw the main content
h2 = patchm(coastlat,coastlon,'EdgeColor',[.8 .8 .8],'FaceColor',[1 1 1]);
h3 = pcolorm(double(lat_map),-180:1.25:178.75,map_pcolorm');
% colorbar
colormap(mycolor);
caxis([0.5 15.5]);
colo = colorbar('south');
colo.Ticks = 1:15;
colo.TickDirection = 'out';
colo.TickLabels = {'Bare Ground','NET Temper.','NET Bor.','NDT Bor.','BET Tropi.', ...
    'BET Temper.','BDT Tropi.','BDT Temper.','BDT Bor.','BES Temper.', ...
    'BDS Temper.','BDS Bor.','C3 arctic grass','C3 grass','C4 grass'};
set(colo, 'Position',[0.402222222222222,0.774422735346356,0.386222222222222,0.026050917702779], 'FontSize',10, 'TickDirection','out');
% set(get(colo, 'Label'), 'string', 'GtC/year',...
%     'FontSize',12,'HorizontalAlignment','center');
tt = title('Dominant PFT','FontSize',12);
tt.Units = 'Normalize';
tt.Position(1) = 0.2;
tt.HorizontalAlignment = 'left';

%% Part 2
%% get the NBP for different PFTs

load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
load procData\landmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
load procData_2311\PFT_domi.mat;

landmask_lnd(isnan(landmask_lnd)) = 0;
landmask_lnd = logical(landmask_lnd);
area_lnd = area_gridbox.*landmask_lnd;

NBP_domiPFT_ts = nan(86,15);    % [years 2015-2100, PFTs 15]

for pp = 1:15
    % get the mask
    pft_mask = PFT_domi == pp;

    % get the area_weight
    pft_area_lnd = area_lnd.*pft_mask;
    pft_area_total = sum(pft_area_lnd,'all','omitnan');
    pft_area_weight = pft_area_lnd./pft_area_total;
    
    % get the weighted C flux
    for yy = 1:86
        if yy <= 9
            NBP_domiPFT_ts(yy,pp) = squeeze(sum(NBP_2015_y(:,:,yy).*pft_area_weight,'all','omitnan'));
        else
            NBP_domiPFT_ts(yy,pp) = squeeze(sum(NBP_2100_y(:,:,yy-9).*pft_area_weight,'all','omitnan'));
        end
    end
end

%% visualization 1: NBP_domiPFT_ts

% figure;
% plot(NBP_domiPFT_ts)

figure('Position',[10 10 600 750]);
colororder(mycolor*0.9)

ax = subplot(2,1,1);
set(ax,'FontSize',11);
p0 = line([9.5 9.5],[-50 50],'Color',[0.7 0.7 0.7],'LineWidth',3);
% p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(NBP_domiPFT_ts);
% ,'LineWidth',1
for ll = [2 3 4 5 8 11 13 14 15]
    p1(ll).LineWidth = 1;
end
hold off
xlim([1 86]);
ylim([-40 30]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Net biome productivity (GtC/year)'})
ax.YGrid = 'on';
% legend
l = legend(p1,'Bare Ground','NET Temper.','NET Bor.','NDT Bor.','BET Tropi.', ...
    'BET Temper.','BDT Tropi.','BDT Temper.','BDT Bor.','BES Temper.', ...
    'BDS Temper.','BDS Bor.','C3 arctic grass','C3 grass','C4 grass');
l.Box = 'off';
l.Location = 'northeast';
l.NumColumns = 3;
l.FontSize = 10;
text(11,-36,'CO_2 removal in 2024','FontSize',12);
% title
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

% visualization 2: cumulative NBP_domiPFT_ts
% figure('Position',[10 10 700 400]);
% colororder(mycolor*0.9)

ax2 = subplot(2,1,2);
set(ax2,'FontSize',11);
cumul_NBP_domiPFT_ts = cumsum(NBP_domiPFT_ts,1);

p0 = line([9.5 9.5],[-500 500],'Color',[0.7 0.7 0.7],'LineWidth',3);
% p0 = line([0 86],[0 0],'Color',[0.5 0.5 0.5],'LineWidth',1);
hold on;
p1 = plot(cumul_NBP_domiPFT_ts);
% ,'LineWidth',1
for ll = [2 3 4 5 8 11 13 14 15]
    p1(ll).LineWidth = 1;
end
hold off
xlim([1 86]);
ylim([-420 150]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Cumulative C fluxes (GtC)'})
ax2.YGrid = 'on';
% legend
l = legend(p1,'Bare Ground','NET Temper.','NET Bor.','NDT Bor.','BET Tropi.', ...
    'BET Temper.','BDT Tropi.','BDT Temper.','BDT Bor.','BES Temper.', ...
    'BDS Temper.','BDS Bor.','C3 arctic grass','C3 grass','C4 grass');
l.Box = 'off';
l.Location = 'southeast';
l.NumColumns = 3;
l.FontSize = 10;
% note
text(11,-390,'CO_2 removal in 2024','FontSize',12);
% title
tt = title('(c)','FontSize',12);
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

%% the PFT indices meaning 

title_pft = {'0 Bare Ground','1 NET Temperate','2 NET Boreal','3 NDT Boreal','4 BET Tropical', ...
    '5 BET Temperate','6 BDT Tropical','7 BDT Temperate','8 BDT Boreal','9 BES Temperate', ...
    '10 BDS Temperate','11 BDS Boreal','12 C3 arctic grass','13 C3 grass','14 C4 grass'};

% IVT
% Plant functional type
% Acronym
% 
% 0
% Bare Ground
% NET Temperate
% 
% 1 Needleleaf evergreen tree – temperate
% NET Temperate

% 2 Needleleaf evergreen tree - boreal
% NET Boreal
% 
% 3 Needleleaf deciduous tree – boreal
% NDT Boreal
% 
% 4 Broadleaf evergreen tree – tropical
% BET Tropical
% 
% 5 Broadleaf evergreen tree – temperate
% 5 BET Temperate
% 
% 6 Broadleaf deciduous tree – tropical
% 6 BDT Tropical
% 
% 7 Broadleaf deciduous tree – temperate
% 7 BDT Temperate
% 
% 8 Broadleaf deciduous tree – boreal
% 8 BDT Boreal
% 
% 9 Broadleaf evergreen shrub - temperate
% 9 BES Temperate
% 
% 10 Broadleaf deciduous shrub – temperate
% 10 BDS Temperate
% 
% 11 Broadleaf deciduous shrub – boreal
% 11 BDS Boreal
% 
% 12 C3 arctic grass
% 
% 13 C3 grass
% 
% 14 C4 grass