% Here calculates the data needed in the schematic figure and draws some
% supplemental figures for readers' information.

% mean: 2015-2023, 2024-2040, 2090-2100
%     GPP, AR, HR, NPP, T, ET, TSA, SoilWater, Water use efficency

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

% ---> group different climate
% 1: tropical: 1:3
% 2: Arid: 4:7
% 3: Temperate: 8:16
% 4: Cold: 17:28 (Boreal)
% 5: Polar: 29:30
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

%% 1.1 GPP, NPP, AR, HR

% load data first
load procData_2311\GPP_2015_y.mat;
load procData_2311\GPP_2100_y.mat;
load procData_2311\NPP_2015_y.mat;
load procData_2311\NPP_2100_y.mat;
load procData_2311\AR_2015_y.mat;
load procData_2311\AR_2100_y.mat;
load procData_2311\HR_2015_y.mat;
load procData_2311\HR_2100_y.mat;
GPP_all = cat(3,GPP_2015_y,GPP_2100_y);
NPP_all = cat(3,NPP_2015_y,NPP_2100_y);
AR_all = cat(3,AR_2015_y,AR_2100_y);
HR_all = cat(3,HR_2015_y,HR_2100_y);

% get the global ts
GPP_ts_y = squeeze(sum(GPP_all.*area_lnd_weight,[1 2],'omitnan'));
NPP_ts_y = squeeze(sum(NPP_all.*area_lnd_weight,[1 2],'omitnan'));
AR_ts_y = squeeze(sum(AR_all.*area_lnd_weight,[1 2],'omitnan'));
HR_ts_y = squeeze(sum(HR_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
GPP_ts_y_mask = nan(86,2);    % [tropic, boreal]
NPP_ts_y_mask = nan(86,2);    % [tropic, boreal]
AR_ts_y_mask = nan(86,2);
HR_ts_y_mask = nan(86,2);
% ts: area-weighted fluxes
for yy = 1:86
    GPP_ts_y_mask(yy,1) = squeeze(sum(GPP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    NPP_ts_y_mask(yy,1) = squeeze(sum(NPP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    AR_ts_y_mask(yy,1) = squeeze(sum(AR_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    HR_ts_y_mask(yy,1) = squeeze(sum(HR_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    GPP_ts_y_mask(yy,2) = squeeze(sum(GPP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    NPP_ts_y_mask(yy,2) = squeeze(sum(NPP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    AR_ts_y_mask(yy,2) = squeeze(sum(AR_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    HR_ts_y_mask(yy,2) = squeeze(sum(HR_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear GPP_all NPP_all AR_all HR_all GPP_2015_y NPP_2015_y GPP_2100_y NPP_2100_y AR_2015_y AR_2100_y HR_2015_y HR_2100_y;

% get the data ---> mean: 2015-2023, 2024-2032, 2090-2100
index_p1 = 1:9;
index_p2 = 10:24;
index_p3 = 77:86;

% mean_GPP = nan(3,3);    % [years; regions (global, tropical, boreal)]
% mean_GPP(1,1) = mean(GPP_ts_y(index_p1));
% mean_GPP(1,2) = mean(GPP_ts_y_mask(index_p1,1));
% mean_GPP(1,3) = mean(GPP_ts_y_mask(index_p1,2));
% mean_GPP(2,1) = mean(GPP_ts_y(index_p2));
% mean_GPP(2,2) = mean(GPP_ts_y_mask(index_p2,1));
% mean_GPP(2,3) = mean(GPP_ts_y_mask(index_p2,2));
% mean_GPP(3,1) = mean(GPP_ts_y(index_p3));
% mean_GPP(3,2) = mean(GPP_ts_y_mask(index_p3,1));
% mean_GPP(3,3) = mean(GPP_ts_y_mask(index_p3,2));
var_name = {'GPP','NPP','AR','HR'};
for var_num = 1:4
    eval(['mean_' var_name{var_num} ' = nan(3,3);'])
    for pp = 1:3
        for rr = 1:3
            if rr == 1
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',1) = mean(' var_name{var_num} '_ts_y(index_p' num2str(pp) '));'])
            else
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',' num2str(rr) ') = mean(' var_name{var_num} '_ts_y_mask(index_p' num2str(pp) ',' num2str(rr-1) '));'])
            end
        end
    end
    % disp(mean_GPP)
    disp(var_name{var_num})
    eval(['disp(mean_' var_name{var_num} ')'])
end

% example
% GPP        (global, x)  (trop.)   (bor.)
%  (2015-2023) 147.4899  305.9538  123.3070
%  (2024-2038) 121.7076  249.1244  105.3787
%  (2091-2100) 123.2355  248.1577  108.1255

% GPP
%   147.4899  305.9538  123.3070
%   121.7076  249.1244  105.3787
%   123.2355  248.1577  108.1255
% NPP
%    59.9019  116.5524   57.3169
%    49.8307   93.9696   50.1684
%    51.0213   95.5755   50.9980
% AR
%    87.5880  189.4014   65.9901
%    71.8769  155.1547   55.2103
%    72.2143  152.5822   57.1275
% HR
%    51.4939   99.3822   49.4776
%    48.2432   93.1559   47.7907
%    47.1515   89.6097   47.3120

%% 1.2 T, ET, TSA

% load data first
load procData_2311\T_2015_y.mat;
load procData_2311\T_2100_y.mat;
load procData_2311\ET_2015_y.mat;
load procData_2311\ET_2100_y.mat;
load procData_2311\TSA_2015_y.mat;
load procData_2311\TSA_2100_y.mat;
T_all = cat(3,T_2015_y,T_2100_y);
ET_all = cat(3,ET_2015_y,ET_2100_y);
TSA_all = cat(3,TSA_2015_y,TSA_2100_y);

% get the global ts
T_ts_y = squeeze(sum(T_all.*area_lnd_weight,[1 2],'omitnan'));
ET_ts_y = squeeze(sum(ET_all.*area_lnd_weight,[1 2],'omitnan'));
TSA_ts_y = squeeze(sum(TSA_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
T_ts_y_mask = nan(86,2);    % [tropic, boreal]
ET_ts_y_mask = nan(86,2);    % [tropic, boreal]
TSA_ts_y_mask = nan(86,2);
% ts: area-weighted fluxes
for yy = 1:86
    T_ts_y_mask(yy,1) = squeeze(sum(T_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    ET_ts_y_mask(yy,1) = squeeze(sum(ET_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    TSA_ts_y_mask(yy,1) = squeeze(sum(TSA_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    T_ts_y_mask(yy,2) = squeeze(sum(T_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    ET_ts_y_mask(yy,2) = squeeze(sum(ET_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    TSA_ts_y_mask(yy,2) = squeeze(sum(TSA_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear T_all ET_all TSA_all T_2015_y ET_2015_y T_2100_y ET_2100_y TSA_2015_y TSA_2100_y;

% get the data ---> mean: 2015-2023, 2024-2038, 2090-2100
index_p1 = 1:9;
index_p2 = 10:24;
index_p3 = 77:86;

% mean_GPP = nan(3,3);    % [years; regions (global, tropical, boreal)]
var_name = {'T','ET','TSA'};
for var_num = 1:3
    eval(['mean_' var_name{var_num} ' = nan(3,3);'])
    for pp = 1:3
        for rr = 1:3
            if rr == 1
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',1) = mean(' var_name{var_num} '_ts_y(index_p' num2str(pp) '));'])
            else
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',' num2str(rr) ') = mean(' var_name{var_num} '_ts_y_mask(index_p' num2str(pp) ',' num2str(rr-1) '));'])
            end
        end
    end
    % disp(mean_GPP)
    disp(var_name{var_num})
    eval(['disp(mean_' var_name{var_num} ')'])
end

% example
% GPP        (global, x)  (trop.)   (bor.)
%  (2015-2023) 147.4899  305.9538  123.3070
%  (2024-2038) 121.7076  249.1244  105.3787
%  (2091-2100) 123.2355  248.1577  108.1255

% T
%    19.6152   41.4080   13.3559
%    20.6538   43.6658   14.2718
%    20.8561   43.4822   14.6726
% ET
%    47.7149   85.8529   30.4783
%    47.8393   86.2785   30.8088
%    48.3996   86.6237   31.8829
% TSA
%    15.5753   26.8349    2.6282
%    14.9571   26.4725    1.8803
%    14.7860   26.4657    1.5975

%% 1.3 Soil water, Water use efficency
% SOILWATER_10CM, ET, NPP

% load data first
load procData_2311\SOILWATER_10CM_2015_y.mat;
load procData_2311\SOILWATER_10CM_2100_y.mat;
load procData_2311\ET_2015_y.mat;
load procData_2311\ET_2100_y.mat;
load procData_2311\NPP_2015_y.mat;
load procData_2311\NPP_2100_y.mat;
SOILWATER_10CM_all = cat(3,SOILWATER_10CM_2015_y,SOILWATER_10CM_2100_y);
ET_all = cat(3,ET_2015_y,ET_2100_y);
NPP_all = cat(3,NPP_2015_y,NPP_2100_y);

% get the global ts
SOILWATER_10CM_ts_y = squeeze(sum(SOILWATER_10CM_all.*area_lnd_weight,[1 2],'omitnan'));
ET_ts_y = squeeze(sum(ET_all.*area_lnd_weight,[1 2],'omitnan'));
NPP_ts_y = squeeze(sum(NPP_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
SOILWATER_10CM_ts_y_mask = nan(86,2);    % [tropic, boreal]
ET_ts_y_mask = nan(86,2);    % [tropic, boreal]
NPP_ts_y_mask = nan(86,2);
% ts: area-weighted fluxes
for yy = 1:86
    SOILWATER_10CM_ts_y_mask(yy,1) = squeeze(sum(SOILWATER_10CM_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    ET_ts_y_mask(yy,1) = squeeze(sum(ET_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    NPP_ts_y_mask(yy,1) = squeeze(sum(NPP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    SOILWATER_10CM_ts_y_mask(yy,2) = squeeze(sum(SOILWATER_10CM_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    ET_ts_y_mask(yy,2) = squeeze(sum(ET_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    NPP_ts_y_mask(yy,2) = squeeze(sum(NPP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear SOILWATER_10CM_all ET_all NPP_all SOILWATER_10CM_2015_y ET_2015_y SOILWATER_10CM_2100_y ET_2100_y NPP_2015_y NPP_2100_y;

% get the data ---> mean: 2015-2023, 2024-2040, 2090-2100
index_p1 = 1:9;
index_p2 = 10:24;
index_p3 = 77:86;

% mean_GPP = nan(3,3);    % [years; regions (global, tropical, boreal)]
var_name = {'SOILWATER_10CM','ET','NPP'};
for var_num = 1:3
    eval(['mean_' var_name{var_num} ' = nan(3,3);'])
    for pp = 1:3
        for rr = 1:3
            if rr == 1
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',1) = mean(' var_name{var_num} '_ts_y(index_p' num2str(pp) '));'])
            else
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',' num2str(rr) ') = mean(' var_name{var_num} '_ts_y_mask(index_p' num2str(pp) ',' num2str(rr-1) '));'])
            end
        end
    end
    % disp(mean_GPP)
    disp(var_name{var_num})
    eval(['disp(mean_' var_name{var_num} ')'])
end

% water use efficiency
WUE = mean_NPP./mean_ET;

% example
% GPP        (global, x)  (trop.)   (bor.)
%  (2015-2023) 147.4899  305.9538  123.3070
%  (2024-2038) 121.7076  249.1244  105.3787
%  (2091-2100) 123.2355  248.1577  108.1255

% SOILWATER_10CM
%    29.9114   30.7564   42.1357
%    29.8457   30.5874   42.4601
%    29.5975   30.5529   41.1967
% ET
%    47.7149   85.8529   30.4783
%    47.8393   86.2785   30.8088
%    48.3996   86.6237   31.8829
% NPP
%    59.9019  116.5524   57.3169
%    49.8307   93.9696   50.1684
%    51.0213   95.5755   50.9980

% WUE =
%     1.2554    1.3576    1.8806
%     1.0416    1.0891    1.6284
%     1.0542    1.1033    1.5995

%% fire and harvest

load procData_2311\FIRE_CLOSS_2015_y.mat;
load procData_2311\FIRE_CLOSS_2100_y.mat;
load procData_2311\FIRE_CLOSS2_2015_y.mat;
load procData_2311\FIRE_CLOSS2_2100_y.mat;
load procData_2311\WOOD_HARVESTC_2015_y.mat;
load procData_2311\WOOD_HARVESTC_2100_y.mat;
FIRE_CLOSS_2015_y = FIRE_CLOSS_2015_y + FIRE_CLOSS2_2015_y;
FIRE_CLOSS_2100_y = FIRE_CLOSS_2100_y + FIRE_CLOSS2_2100_y;
FIRE_CLOSS_all = cat(3,FIRE_CLOSS_2015_y,FIRE_CLOSS_2100_y);
Harvest_all = cat(3,WOOD_HARVESTC_2015_y,WOOD_HARVESTC_2100_y);

% get the global ts
FIRE_CLOSS_ts_y = squeeze(sum(FIRE_CLOSS_all.*area_lnd_weight,[1 2],'omitnan'));
Harvest_ts_y = squeeze(sum(Harvest_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
FIRE_CLOSS_ts_y_mask = nan(86,2);    % [tropic, boreal]
Harvest_ts_y_mask = nan(86,2);    % [tropic, boreal]
% ts: area-weighted fluxes
for yy = 1:86
    FIRE_CLOSS_ts_y_mask(yy,1) = squeeze(sum(FIRE_CLOSS_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    Harvest_ts_y_mask(yy,1) = squeeze(sum(Harvest_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    FIRE_CLOSS_ts_y_mask(yy,2) = squeeze(sum(FIRE_CLOSS_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
    Harvest_ts_y_mask(yy,2) = squeeze(sum(Harvest_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear FIRE_CLOSS_2015_y FIRE_CLOSS_2100_y FIRE_CLOSS2_2015_y FIRE_CLOSS2_2100_y WOOD_HARVESTC_2015_y WOOD_HARVESTC_2100_y;

% get the data ---> mean: 2015-2023, 2024-2038, 2090-2100
index_p1 = 1:9;
index_p2 = 10:24;
index_p3 = 77:86;

% mean_GPP = nan(3,3);    % [years; regions (global, tropical, boreal)]
var_name = {'FIRE_CLOSS','Harvest'};
for var_num = 1:2
    eval(['mean_' var_name{var_num} ' = nan(3,3);'])
    for pp = 1:3
        for rr = 1:3
            if rr == 1
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',1) = mean(' var_name{var_num} '_ts_y(index_p' num2str(pp) '));'])
            else
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',' num2str(rr) ') = mean(' var_name{var_num} '_ts_y_mask(index_p' num2str(pp) ',' num2str(rr-1) '));'])
            end
        end
    end
    % disp(mean_GPP)
    disp(var_name{var_num})
    eval(['disp(mean_' var_name{var_num} ')'])
end

% example
% GPP        (global, x)  (trop.)   (bor.)
%  (2015-2023) 147.4899  305.9538  123.3070
%  (2024-2038) 121.7076  249.1244  105.3787
%  (2091-2100) 123.2355  248.1577  108.1255

% FIRE_CLOSS
%     2.4016    5.3138    1.3052
%     2.0830    4.8452    0.9299
%     1.8609    3.7623    1.5830
% Harvest
%     0.7597    1.2858    0.7448
%     0.7004    1.1254    0.7785
%     0.5366    0.8680    0.5449

%% 1.4 NBP

% load data first
load procData_2311\NBP_2015_y.mat;
load procData_2311\NBP_2100_y.mat;
NBP_all = cat(3,NBP_2015_y,NBP_2100_y);

% get the global ts
NBP_ts_y = squeeze(sum(NBP_all.*area_lnd_weight,[1 2],'omitnan'));

% get the tropic & boreal ts
NBP_ts_y_mask = nan(86,2);    % [tropic, boreal]
% ts: area-weighted fluxes
for yy = 1:86
    NBP_ts_y_mask(yy,1) = squeeze(sum(NBP_all(:,:,yy).*tropic_area_weight,'all','omitnan'));
    NBP_ts_y_mask(yy,2) = squeeze(sum(NBP_all(:,:,yy).*boreal_area_weight,'all','omitnan'));
end
clear NBP_all NBP_2015_y NBP_2100_y;

% get the data ---> mean: 2015-2023, 2024-2040, 2090-2100
index_p1 = 1:9;
index_p2 = 10:18;
index_p3 = 77:86;

% mean_GPP = nan(3,3);    % [years; regions (global, tropical, boreal)]
var_name = {'NBP'};
% for var_num = 1:3
var_num = 1;
    eval(['mean_' var_name{var_num} ' = nan(3,3);'])
    for pp = 1:3
        for rr = 1:3
            if rr == 1
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',1) = mean(' var_name{var_num} '_ts_y(index_p' num2str(pp) '));'])
            else
                eval(['mean_' var_name{var_num} '(' num2str(pp) ',' num2str(rr) ') = mean(' var_name{var_num} '_ts_y_mask(index_p' num2str(pp) ',' num2str(rr-1) '));'])
            end
        end
    end
    % disp(mean_GPP)
    disp(var_name{var_num})
    eval(['disp(mean_' var_name{var_num} ')'])
% end

% NBP
%     4.0520    9.1906    4.6252
%    -3.3188   -9.5472   -0.6802
%     0.1732   -0.6510    0.6604


%% Results

% [ROW: years; COL: regions (global, tropical, boreal)]

% GPP
%   147.4899  305.9538  123.3070
%   121.9859  249.8840  105.3386
%   123.2355  248.1577  108.1255

% NPP
%    59.9019  116.5524   57.3169
%    49.9376   94.2704   50.1850
%    51.0213   95.5755   50.9980

% AR
%    87.5880  189.4014   65.9901
%    72.0482  155.6136   55.1536
%    72.2143  152.5822   57.1275

% HR
%    51.4939   99.3822   49.4776
%    48.1664   93.0201   47.6451
%    47.1515   89.6097   47.3120

% T
%    19.6152   41.4080   13.3559
%    20.6698   43.7147   14.2500
%    20.8561   43.4822   14.6726

% ET
%    47.7149   85.8529   30.4783
%    47.8423   86.3112   30.7721
%    48.3996   86.6237   31.8829

% TSA
%    15.5753   26.8349    2.6282
%    14.9215   26.4496    1.8188
%    14.7860   26.4657    1.5975

% SOILWATER_10CM
%    29.9114   30.7564   42.1357
%    29.8325   30.5916   42.4116
%    29.5975   30.5529   41.1967

% Water use efficieny
%     1.2554    1.3576    1.8806
%     1.0438    1.0922    1.6309
%     1.0542    1.1033    1.5995

% NBP
%     4.0520    9.1906    4.6252
%    -2.1058   -6.6190   -0.0688
%     0.1732   -0.6510    0.6604







