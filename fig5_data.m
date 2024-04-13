% Here imitates the historical figures, but with observation-based datasets
% to draw the figure and do the analysis.

% DATA SOURCE (land use emissions and CO2): https://essd.copernicus.org/articles/15/5301/2023/#section6
% co2: https://gml.noaa.gov/ccgg/trends/data.html

clear;
clc;

%% data for time series

p = 'E:\research\D_CDR\GCB\Global_Carbon_Budget_2023v1.0.xlsx';
historical_data = xlsread(p,'Historical Budget');

% use this date_yymm as time index
date_used = datevec(datenum(1850,1,1):1:datenum(2022,12,31));
date_yymm = unique(date_used(:,1:2),'rows');
date_yy = unique(date_used(:,1),"rows");
GCB_days_of_month(:,[1 2]) = unique(date_used(:,1:2),'rows');
for i = 1:1980
    GCB_days_of_month(i,3) = sum(date_used(:,1) == GCB_days_of_month(i,1) & date_used(:,2) == GCB_days_of_month(i,2));
end

% 'NBP': units: GtC/yr
E_LU = historical_data(101:273,3);
S_L = historical_data(101:273,6);
hist_NBP = - E_LU + S_L;

% cdr
load procData_2311\CO2_2100_ts_y.mat;
load procData_2311\NBP_2100_ts_y.mat;

% CESM2 historical co2 till 2014
load procData_hist\hist_co2_AERmon_ts_y.mat;
% map
load procData_hist\hist_nbp_y.mat;
load procData_hist\ssp1_nbp_y.mat;
cesm_NBP = cat(3,hist_nbp_y,ssp1_nbp_y(:,:,1:8));
% ts
load procData_hist\hist_nbp_ts_y.mat;
load procData_hist\ssp1_nbp_ts_y.mat;
cesm_NBP_ts = [hist_nbp_ts_y; ssp1_nbp_ts_y(1:8,1)];


% NOAA/GML surface average
co2_1522 = [401.01
404.41
406.76
408.72
411.65
414.21
416.41
418.53];
co2_stitch = [hist_co2_AERmon_ts_y; co2_1522];

% get the sorted data
[co2_sorted, co2_I] = sort(co2_stitch);
[sort_co2_cdr,sort_index_cdr] = sort(CO2_2100_ts_y);

%% Get the tropicl & boreal differences
% Here calculates the NBP in historical & SSP & CDR of the tropical and
% boreal regions, and compare them with the atmospheric CO2 consentrations,
% and lead to the discussion of their sensitivity to CO2, and perhaps other
% climatic factors.

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

%% 1. CDR: get the NBP ts for different climate zones

cdr_NBP_KG_ts = nan(86,5);    % [years 2015-2100, climate zones 5]
cdr_NBP_cumulKG_ts = nan(86,5);
for i = 1:5
    % get the mask
    KG_mask = KG_classes == i;

    % get the area_weight
    KG_area_lnd = area_lnd.*KG_mask;
    KG_area_total = sum(KG_area_lnd,'all','omitnan');
    KG_area_weight = KG_area_lnd./KG_area_total;
    
    % get the weighted C flux & cumulative C
    for yy = 1:86
        cdr_NBP_KG_ts(yy,i) = squeeze(sum(NBP_all(:,:,yy).*KG_area_weight,'all','omitnan'));
        cdr_NBP_cumulKG_ts(yy,i) = squeeze(sum(NBP_cum(:,:,yy).*KG_area_weight,'all','omitnan'));
    end
end
cdr_NBP_cumulKG_2100_ts = cdr_NBP_cumulKG_ts(10:end,:) - cdr_NBP_cumulKG_ts(9,:);

%% 2. historical: get the NBP ts for different climate zones

% CESM2 historical co2 till 2014
load procData_hist\hist_co2_AERmon_y.mat;
load procData_hist\hist_nbp_y.mat;

cesm_NBP_KG_ts = nan(86,5);    % [years 1850-2022, climate zones 5]
cesm_NBP_cumulKG_ts = nan(86,5);
for i = 1:5
    % get the mask
    KG_mask = KG_classes == i;

    % get the area_weight
    KG_area_lnd = area_lnd.*KG_mask;
    KG_area_total = sum(KG_area_lnd,'all','omitnan');
    KG_area_weight = KG_area_lnd./KG_area_total;
    
    % get the weighted C flux & cumulative C
    for yy = 1:173
        cesm_NBP_KG_ts(yy,i) = squeeze(sum(cesm_NBP(:,:,yy).*KG_area_weight,'all','omitnan'));
        cesm_NBP_cumulKG_ts(yy,i) = squeeze(sum(cesm_NBP(:,:,yy).*KG_area_weight,'all','omitnan'));
    end
end

