% Here shows the area changes of the map

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

load procData\area_lnd_weight.mat;
load procData\landmask_lnd.mat;
load procData\area_gridbox.mat;     % km^2
landmask_lnd(:,1:33) = nan;
total_land_area = sum(area_gridbox.*landmask_lnd,"all",'omitnan')*1e6; % km^2 -> m^2
% get new area_lnd_weight
area_lnd = area_gridbox.*landmask_lnd*1e6;
area_lnd_weight = area_lnd./total_land_area;

% get the main data
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);

%% absolute areas
% the results look asymmetry, but the source area slightly increasing relative to the average of sink and source areas.

sink_all = NBP_all > 0;
sour_all = NBP_all < 0;
ss_area = nan(86,2);    % 2: sink, source
for yy = 1:86
    ss_area(yy,1) = sum(sink_all(:,:,yy).*area_lnd/1e6,'all','omitnan');
    ss_area(yy,2) = sum(sour_all(:,:,yy).*area_lnd/1e6,'all','omitnan');
end

% relative ratios
% total areas
total_area = sum(area_lnd/1e6,'all','omitnan');
ss_ratio = ss_area/total_area;

%% visualization

color_here = [26,166,64; 128,64,230; 150,150,150]/255;

figure('Position',[10,10,450,360]);
colororder(color_here);
hold on;
p0 = line([9.5 9.5],[-30 30],'Color',[0.7 0.7 0.7],'LineWidth',3);
p0_0 = line([0 86],[0.5 0.5],'Color',[0.7 0.7 0.7],'LineWidth',1);
p1 = plot(ss_ratio,'LineWidth',1);
xlim([1 86]);
ylim([0.1 0.9]);
xticks([1 10 16:10:86]);
xticklabels({'2015','2024','2030','2040','2050','2060','2070','2080','2090','2100'});
ylabel({'Area ratio';'(of total land area)'});
a1.YGrid = 'on';
% legend
l = legend([p1(1),p1(2)],'Carbon sink (NBP < 0)','Carbon source (NBP > 0)');
l.Box = 'off';
l.Location = 'northeast';
l.FontSize = 10;




