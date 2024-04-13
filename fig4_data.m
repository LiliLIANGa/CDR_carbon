% Here completes the data missed in the template of our schematic figure.
% Contents include: 
%   1. supplemental variables: C fixation from sunlit/shaded leaves
%   2. supplemental variables: ET, T
%   3. calculation: T/ET, NPP/ET (water use efficiency) (NPP)

% ******* Task 3. in another *.m file

% c.f. 
%   1. E:\research\D_CDR\2311_12\codes_2311\b0_data_preparation.m
%   2. E:\research\D_CDR\2309\a4_yearly_keyVars_2_energy_photosynthesis.m

% Attributes of the variables:
% water (T, ET) 
%   FCEV (W/m^2): canopy evaporation
%   FCTR (W/m^2): canopy transpiration        (get from lnd)
%   FGEV (W/m^2): ground evaporation
%   H2OCAN (mm): intercepted water
%   LHFLX (W/m2): surface latent heat flux    (get from cam)
% Photosynthesis (C fixation)
%   PSNSHADE_TO_CPOOL (gC/m^2/s): C fixation from shaded canopy
%   PSNSUN_TO_CPOOL (gC/m^2/s): C fixation from sunlit canopy

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

% data attributes
lnd_info = ncinfo('E:\CESMoutput\lnd\Exp1\test.BSSP126cmip6_BPRP.clm2.h0.2015-01.nc');

%% T and ET (W/m^2)

% T
%   FCTR (W/m^2): canopy transpiration        (get from lnd)
load E:\research\D_CDR\data_lnd\ex4_FCTR.mat;
T_2100 = ex4_FCTR;
clear ex4_FCTR;
load E:\research\D_CDR\test_output\lnd_ex1\FCTR.mat;
T_2015 = FCTR(:,:,1:108);
clear FCTR;

% ET
%   LHFLX (W/m2): surface latent heat flux    (get from cam)
load E:\research\D_CDR\data_cam\ex4_LHFLX.mat;
ET_2100 = ex4_LHFLX;
clear ex4_LHFLX;
load E:\research\D_CDR\test_output\cam_ex1\LHFLX.mat;
ET_2015 = LHFLX(:,:,1:108);
clear LHFLX;

% get yearly data
T_2100_y = nan(288,192,77);
T_2015_y = nan(288,192,9);
ET_2100_y = nan(288,192,77);
ET_2015_y = nan(288,192,9);
for i = 1:77
    if i <= 9
        T_2015_y(:,:,i) = mean(T_2015(:,:,days_of_month_2015(:,1) == i+2014),3,'omitnan');
        ET_2015_y(:,:,i) = mean(ET_2015(:,:,days_of_month_2015(:,1) == i+2014),3,'omitnan');
    end
    T_2100_y(:,:,i) = mean(T_2100(:,:,days_of_month_2100(:,1) == i+2023),3,'omitnan');
    ET_2100_y(:,:,i) = mean(ET_2100(:,:,days_of_month_2100(:,1) == i+2023),3,'omitnan');
end

% ts
T_2015_ts = squeeze(sum(T_2015.*area_lnd_weight,[1 2],'omitnan'));
T_2100_ts = squeeze(sum(T_2100.*area_lnd_weight,[1 2],'omitnan'));
ET_2015_ts = squeeze(sum(ET_2015.*area_lnd_weight,[1 2],'omitnan'));
ET_2100_ts = squeeze(sum(ET_2100.*area_lnd_weight,[1 2],'omitnan'));

% get yearly ts
T_2015_ts_y = nan(9,1);
T_2100_ts_y = nan(77,1);
ET_2015_ts_y = nan(9,1);
ET_2100_ts_y = nan(77,1);
for i = 1:77
    if i <= 9
        T_2015_ts_y(i,1) = mean(T_2015_ts(days_of_month_2015(:,1) == i+2014,1),'all','omitnan');
        ET_2015_ts_y(i,1) = mean(ET_2015_ts(days_of_month_2015(:,1) == i+2014,1),'all','omitnan');
    end
    T_2100_ts_y(i,1) = mean(T_2100_ts(days_of_month_2100(:,1) == i+2023,1),'all','omitnan');
    ET_2100_ts_y(i,1) = mean(ET_2100_ts(days_of_month_2100(:,1) == i+2023,1),'all','omitnan');
end

save procData_2311\T_2015.mat T_2015;
save procData_2311\T_2100.mat T_2100;
save procData_2311\T_2015_y.mat T_2015_y;
save procData_2311\T_2100_y.mat T_2100_y;
save procData_2311\T_2015_ts_y.mat T_2015_ts_y;
save procData_2311\T_2100_ts_y.mat T_2100_ts_y;

save procData_2311\ET_2015.mat ET_2015;
save procData_2311\ET_2100.mat ET_2100;
save procData_2311\ET_2015_y.mat ET_2015_y;
save procData_2311\ET_2100_y.mat ET_2100_y;
save procData_2311\ET_2015_ts_y.mat ET_2015_ts_y;
save procData_2311\ET_2100_ts_y.mat ET_2100_ts_y;

%% Photosynthesis (C fixation)
%   PSNSHADE_TO_CPOOL (gC/m^2/s): C fixation from shaded canopy
%   PSNSUN_TO_CPOOL (gC/m^2/s): C fixation from sunlit canopy

% load data
load E:\research\D_CDR\data_lnd\ex4_PSNSHADE_TO_CPOOL.mat;
load E:\research\D_CDR\data_lnd\ex4_PSNSUN_TO_CPOOL.mat;
PSNSHADE_TO_CPOOL_2100 = ex4_PSNSHADE_TO_CPOOL;
PSNSUN_TO_CPOOL_2100 = ex4_PSNSUN_TO_CPOOL;
clear ex4_PSNSHADE_TO_CPOOL ex4_PSNSUN_TO_CPOOL;

load E:\research\D_CDR\test_output\lnd_ex1\PSNSHADE_TO_CPOOL.mat;
load E:\research\D_CDR\test_output\lnd_ex1\PSNSUN_TO_CPOOL.mat;
PSNSHADE_TO_CPOOL_2015 = PSNSHADE_TO_CPOOL(:,:,1:108);
PSNSUN_TO_CPOOL_2015 = PSNSUN_TO_CPOOL(:,:,1:108);
clear PSNSHADE_TO_CPOOL PSNSUN_TO_CPOOL;

% unit transfer: gC/m^2/s -> GtC/year
% *total_land_area*total_secs_year/1e15;
for i = 1:924
    if i <= 108
        days_of_year = sum(days_of_month_2015(days_of_month_2015(:,1) == date_yy_2015(ceil(i/12),1),3),'all');
        total_secs_year = 86400*days_of_year;
        PSNSHADE_TO_CPOOL_2015(:,:,i) = PSNSHADE_TO_CPOOL_2015(:,:,i).*(total_land_area*total_secs_year/1e15);
        PSNSUN_TO_CPOOL_2015(:,:,i) = PSNSUN_TO_CPOOL_2015(:,:,i).*(total_land_area*total_secs_year/1e15);
    end
    days_of_year = sum(days_of_month_2100(days_of_month_2100(:,1) == date_yy_2100(ceil(i/12),1),3),'all');
    total_secs_year = 86400*days_of_year;
    PSNSHADE_TO_CPOOL_2100(:,:,i) = PSNSHADE_TO_CPOOL_2100(:,:,i).*(total_land_area*total_secs_year/1e15);
    PSNSUN_TO_CPOOL_2100(:,:,i) = PSNSUN_TO_CPOOL_2100(:,:,i).*(total_land_area*total_secs_year/1e15);
end

% get yearly data
%   PSNSHADE_TO_CPOOL (gC/m^2/s): C fixation from shaded canopy
%   PSNSUN_TO_CPOOL (gC/m^2/s): C fixation from sunlit canopy
PSNSHADE_TO_CPOOL_2100_y = nan(288,192,77);
PSNSHADE_TO_CPOOL_2015_y = nan(288,192,9);
PSNSUN_TO_CPOOL_2100_y = nan(288,192,77);
PSNSUN_TO_CPOOL_2015_y = nan(288,192,9);
for i = 1:77
    if i <= 9
        PSNSHADE_TO_CPOOL_2015_y(:,:,i) = mean(PSNSHADE_TO_CPOOL_2015(:,:,days_of_month_2015(:,1) == i+2014),3,'omitnan');
        PSNSUN_TO_CPOOL_2015_y(:,:,i) = mean(PSNSUN_TO_CPOOL_2015(:,:,days_of_month_2015(:,1) == i+2014),3,'omitnan');
    end
    PSNSHADE_TO_CPOOL_2100_y(:,:,i) = mean(PSNSHADE_TO_CPOOL_2100(:,:,days_of_month_2100(:,1) == i+2023),3,'omitnan');
    PSNSUN_TO_CPOOL_2100_y(:,:,i) = mean(PSNSUN_TO_CPOOL_2100(:,:,days_of_month_2100(:,1) == i+2023),3,'omitnan');
end

% ts
PSNSHADE_TO_CPOOL_2015_ts = squeeze(sum(PSNSHADE_TO_CPOOL_2015.*area_lnd_weight,[1 2],'omitnan'));
PSNSHADE_TO_CPOOL_2100_ts = squeeze(sum(PSNSHADE_TO_CPOOL_2100.*area_lnd_weight,[1 2],'omitnan'));
PSNSUN_TO_CPOOL_2015_ts = squeeze(sum(PSNSUN_TO_CPOOL_2015.*area_lnd_weight,[1 2],'omitnan'));
PSNSUN_TO_CPOOL_2100_ts = squeeze(sum(PSNSUN_TO_CPOOL_2100.*area_lnd_weight,[1 2],'omitnan'));

% get yearly ts
PSNSHADE_TO_CPOOL_2015_ts_y = nan(9,1);
PSNSHADE_TO_CPOOL_2100_ts_y = nan(77,1);
PSNSUN_TO_CPOOL_2015_ts_y = nan(9,1);
PSNSUN_TO_CPOOL_2100_ts_y = nan(77,1);
for i = 1:77
    if i <= 9
        PSNSHADE_TO_CPOOL_2015_ts_y(i,1) = mean(PSNSHADE_TO_CPOOL_2015_ts(days_of_month_2015(:,1) == i+2014,1),'all','omitnan');
        PSNSUN_TO_CPOOL_2015_ts_y(i,1) = mean(PSNSUN_TO_CPOOL_2015_ts(days_of_month_2015(:,1) == i+2014,1),'all','omitnan');
    end
    PSNSHADE_TO_CPOOL_2100_ts_y(i,1) = mean(PSNSHADE_TO_CPOOL_2100_ts(days_of_month_2100(:,1) == i+2023,1),'all','omitnan');
    PSNSUN_TO_CPOOL_2100_ts_y(i,1) = mean(PSNSUN_TO_CPOOL_2100_ts(days_of_month_2100(:,1) == i+2023,1),'all','omitnan');
end

save procData_2311\PSNSHADE_TO_CPOOL_2015.mat PSNSHADE_TO_CPOOL_2015;
save procData_2311\PSNSHADE_TO_CPOOL_2100.mat PSNSHADE_TO_CPOOL_2100;
save procData_2311\PSNSHADE_TO_CPOOL_2015_y.mat PSNSHADE_TO_CPOOL_2015_y;
save procData_2311\PSNSHADE_TO_CPOOL_2100_y.mat PSNSHADE_TO_CPOOL_2100_y;
save procData_2311\PSNSHADE_TO_CPOOL_2015_ts_y.mat PSNSHADE_TO_CPOOL_2015_ts_y;
save procData_2311\PSNSHADE_TO_CPOOL_2100_ts_y.mat PSNSHADE_TO_CPOOL_2100_ts_y;

save procData_2311\PSNSUN_TO_CPOOL_2015.mat PSNSUN_TO_CPOOL_2015;
save procData_2311\PSNSUN_TO_CPOOL_2100.mat PSNSUN_TO_CPOOL_2100;
save procData_2311\PSNSUN_TO_CPOOL_2015_y.mat PSNSUN_TO_CPOOL_2015_y;
save procData_2311\PSNSUN_TO_CPOOL_2100_y.mat PSNSUN_TO_CPOOL_2100_y;
save procData_2311\PSNSUN_TO_CPOOL_2015_ts_y.mat PSNSUN_TO_CPOOL_2015_ts_y;
save procData_2311\PSNSUN_TO_CPOOL_2100_ts_y.mat PSNSUN_TO_CPOOL_2100_ts_y;


