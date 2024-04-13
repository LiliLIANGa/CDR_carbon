% Here draws the relavent variables to the NBP changes.
% 1. NBP partitioning
% 2. Forest structure relating to photosynthesis
% 3. Other climatic variables (temperature and soil water)

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

% boreal/tropic masks: (1 tropical, 2 Arid, 3 Temperate, 4 Cold (Boreal), 5 Polar)
load procData_2311\KG_classes.mat;
mask_tropic = KG_classes == 1;
mask_boreal = KG_classes == 4;

% get tropic/boreal weight
tropic_area = area_lnd.*mask_tropic;
tropic_area_total = sum(tropic_area,'all','omitnan');
tropic_area_weight = tropic_area./tropic_area_total;
boreal_area = area_lnd.*mask_boreal;
boreal_area_total = sum(boreal_area,'all','omitnan');
boreal_area_weight = boreal_area./boreal_area_total;

%% 1.1 NBP partitioning
% main data for analysis

load procData_2311\GPP_2015_y.mat;
load procData_2311\GPP_2100_y.mat;
load procData_2311\AR_2015_y.mat;
load procData_2311\AR_2100_y.mat;
load procData_2311\HR_2015_y.mat;
load procData_2311\HR_2100_y.mat;
GPP_all = cat(3,GPP_2015_y,GPP_2100_y);
AR_all = cat(3,AR_2015_y,AR_2100_y);
HR_all = cat(3,HR_2015_y,HR_2100_y);

% get the global ts
GPP_ts_y = squeeze(sum(GPP_all.*area_lnd_weight,[1 2],'omitnan'));
AR_ts_y = squeeze(sum(AR_all.*area_lnd_weight,[1 2],'omitnan'));
HR_ts_y = squeeze(sum(HR_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
GPP_ts_y_mask = nan(86,2);    % [tropic, boreal]
AR_ts_y_mask = nan(86,2);
HR_ts_y_mask = nan(86,2);
% ts: area-weighted fluxes
for yy = 1:86
    GPP_ts_y_mask(yy,1) = squeeze(sum(GPP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    AR_ts_y_mask(yy,1) = squeeze(sum(AR_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    HR_ts_y_mask(yy,1) = squeeze(sum(HR_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    GPP_ts_y_mask(yy,2) = squeeze(sum(GPP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    AR_ts_y_mask(yy,2) = squeeze(sum(AR_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    HR_ts_y_mask(yy,2) = squeeze(sum(HR_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear GPP_2015_y GPP_2100_y AR_2015_y AR_2100_y HR_2015_y HR_2100_y;

% fire & harvest
load procData_2311\FIRE_CLOSS_2015_y.mat;
load procData_2311\FIRE_CLOSS_2100_y.mat;
load procData_2311\FIRE_CLOSS2_2015_y.mat;
load procData_2311\FIRE_CLOSS2_2100_y.mat;
load procData_2311\WOOD_HARVESTC_2015_y.mat;
load procData_2311\WOOD_HARVESTC_2100_y.mat;
FIRE_CLOSS_2015_y = FIRE_CLOSS_2015_y + FIRE_CLOSS2_2015_y;
FIRE_CLOSS_2100_y = FIRE_CLOSS_2100_y + FIRE_CLOSS2_2100_y;
Fire_all = cat(3,FIRE_CLOSS_2015_y,FIRE_CLOSS_2100_y);
Harvest_all = cat(3,WOOD_HARVESTC_2015_y,WOOD_HARVESTC_2100_y);

% get the global ts
Fire_ts_y = squeeze(sum(Fire_all.*area_lnd_weight,[1 2],'omitnan'));
Harvest_ts_y = squeeze(sum(Harvest_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
Fire_ts_y_mask = nan(86,2);    % [tropic, boreal]
Harvest_ts_y_mask = nan(86,2);
for yy = 1:86
    Fire_ts_y_mask(yy,1) = squeeze(sum(Fire_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    Harvest_ts_y_mask(yy,1) = squeeze(sum(Harvest_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    Fire_ts_y_mask(yy,2) = squeeze(sum(Fire_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    Harvest_ts_y_mask(yy,2) = squeeze(sum(Harvest_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear FIRE_CLOSS_2015_y FIRE_CLOSS_2100_y WOOD_HARVESTC_2015_y WOOD_HARVESTC_2100_y;

%% 1.2 LAI
% main data for analysis: TLAI, PSNSUN_TO_CPOOL, PSNSHADE_TO_CPOOL

load procData_2311\TLAI_2015_y.mat;
load procData_2311\TLAI_2100_y.mat;
load procData_2311\PSNSUN_TO_CPOOL_2015_y.mat;
load procData_2311\PSNSUN_TO_CPOOL_2100_y.mat;
load procData_2311\PSNSHADE_TO_CPOOL_2015_y.mat;
load procData_2311\PSNSHADE_TO_CPOOL_2100_y.mat;
TLAI_all = cat(3,TLAI_2015_y,TLAI_2100_y);
PSNSUN_TO_CPOOL_all = cat(3,PSNSUN_TO_CPOOL_2015_y,PSNSUN_TO_CPOOL_2100_y);
PSNSHADE_TO_CPOOL_all = cat(3,PSNSHADE_TO_CPOOL_2015_y,PSNSHADE_TO_CPOOL_2100_y);

% get the global ts
TLAI_ts_y = squeeze(sum(TLAI_all.*area_lnd_weight,[1 2],'omitnan'));
PSNSUN_TO_CPOOL_ts_y = squeeze(sum(PSNSUN_TO_CPOOL_all.*area_lnd_weight,[1 2],'omitnan'));
PSNSHADE_TO_CPOOL_ts_y = squeeze(sum(PSNSHADE_TO_CPOOL_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
TLAI_ts_y_mask = nan(86,2);    % [tropic, boreal]
PSNSUN_TO_CPOOL_ts_y_mask = nan(86,2);
PSNSHADE_TO_CPOOL_ts_y_mask = nan(86,2);
% ts: area-weighted fluxes: TLAI, PSNSUN_TO_CPOOL, PSNSHADE_TO_CPOOL
for yy = 1:86
    TLAI_ts_y_mask(yy,1) = squeeze(sum(TLAI_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    PSNSUN_TO_CPOOL_ts_y_mask(yy,1) = squeeze(sum(PSNSUN_TO_CPOOL_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    PSNSHADE_TO_CPOOL_ts_y_mask(yy,1) = squeeze(sum(PSNSHADE_TO_CPOOL_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    TLAI_ts_y_mask(yy,2) = squeeze(sum(TLAI_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    PSNSUN_TO_CPOOL_ts_y_mask(yy,2) = squeeze(sum(PSNSUN_TO_CPOOL_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    PSNSHADE_TO_CPOOL_ts_y_mask(yy,2) = squeeze(sum(PSNSHADE_TO_CPOOL_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear TLAI_2015_y TLAI_2100_y PSNSUN_TO_CPOOL_2015_y PSNSUN_TO_CPOOL_2100_y PSNSHADE_TO_CPOOL_2015_y PSNSHADE_TO_CPOOL_2100_y;

%% 1.3 Climatic factors
% c.f. E:\research\D_CDR\2311_12\codes_2311\b3_climatic_factors_T.m

load procData_2311\TSA_2015_y.mat;
load procData_2311\TSA_2100_y.mat;
load procData_2311\SOILWATER_10CM_2015_y.mat;
load procData_2311\SOILWATER_10CM_2100_y.mat;
TSA_all = cat(3,TSA_2015_y,TSA_2100_y);
SOILWATER_10CM_all = cat(3,SOILWATER_10CM_2015_y,SOILWATER_10CM_2100_y);

% get the global ts
TSA_ts_y = squeeze(sum(TSA_all.*area_lnd_weight,[1 2],'omitnan'));
SOILWATER_10CM_ts_y = squeeze(sum(SOILWATER_10CM_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
TSA_ts_y_mask = nan(86,2);    % [tropic, boreal]
SOILWATER_10CM_ts_y_mask = nan(86,2);
for yy = 1:86
    TSA_ts_y_mask(yy,1) = squeeze(sum(TSA_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    SOILWATER_10CM_ts_y_mask(yy,1) = squeeze(sum(SOILWATER_10CM_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    TSA_ts_y_mask(yy,2) = squeeze(sum(TSA_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    SOILWATER_10CM_ts_y_mask(yy,2) = squeeze(sum(SOILWATER_10CM_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear TSA_2015_y TSA_2100_y SOILWATER_10CM_2015_y SOILWATER_10CM_2100_y;

%% NBP

load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);

% get the global ts
NBP_ts_y = squeeze(sum(NBP_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
NBP_ts_y_mask = nan(86,2);    % [tropic, boreal]
for yy = 1:86
    NBP_ts_y_mask(yy,1) = squeeze(sum(NBP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    NBP_ts_y_mask(yy,2) = squeeze(sum(NBP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear NBP_2015_y NBP_2100_y;


%% clear

clear GPP_all AR_all HR_all Fire_all Harvest_all TLAI_all;
clear PSNSUN_TO_CPOOL_all PSNSHADE_TO_CPOOL_all NBP_all SOILWATER_10CM_all;