% closely follows d1_fig5_0_GCB.m, and based on d1_fig5_1_GCB_ori.m



%% visualization

figure('Position',[10,10,700,700]);

%% subplot 1 -> tropical and boreal difference (?)
% no illustration of the equilibrium balls

a1 = subplot(2,1,1);
p0 = line([0 440],[0 0],'Color',[0.7 0.7 0.7],'LineWidth',1);
hold on;

% area
[~, aa_trop1, aa_trop2] = anomaly(CO2_2100_ts_y(sort_index_cdr,1),cdr_NBP_KG_ts(sort_index_cdr + 9,1),'color','none','top','none','bottom',[218 158 132]/255);
[~, aa_bor1, aa_bor2] = anomaly(CO2_2100_ts_y(sort_index_cdr,1),cdr_NBP_KG_ts(sort_index_cdr + 9,4),'color','none','top','none','bottom',[0.3 0.3 0.4]);
aa_trop2.FaceAlpha = 0.5;
aa_bor2.FaceAlpha = 0.5;

% cesm: ts of hist (cesm) tropical and boreal NBP against CO2 concentrations
% 1: tropical, 4: boreal
% pp1 = plot(co2_sorted,cesm_NBP_KG_ts(co2_I,1),'Color',[0.6 0.6 0.6],'LineWidth',0.7);
% pp2 = plot(co2_sorted,cesm_NBP_KG_ts(co2_I,4),'Color',[0.2 0.2 0.2],'LineWidth',0.7);
pp1 = plot(co2_sorted,cesm_NBP_KG_ts(co2_I,1),'Color',[218 158 132]/255,'LineWidth',0.8);
pp2 = plot(co2_sorted,cesm_NBP_KG_ts(co2_I,4),'Color',[0.3 0.3 0.4],'LineWidth',0.7);

% cdr
% tropcial
ss_trop = scatter(CO2_2100_ts_y,cdr_NBP_KG_ts(10:86,1),'filled');
ss_trop.MarkerEdgeColor = 'none';
ss_trop.MarkerFaceColor = [186 94 82]/255;
ss_trop.MarkerFaceAlpha = 0.7;
ss_trop.SizeData = 10;
% boreal
ss_bore = scatter(CO2_2100_ts_y,cdr_NBP_KG_ts(10:86,4),'filled');
ss_bore.MarkerEdgeColor = 'none';
ss_bore.MarkerFaceColor = [0.5 0.5 0.5];
ss_bore.MarkerFaceAlpha = 0.7;
ss_bore.SizeData = 10;

% other setting
xlim([280 430]);
ylim([-25 10]);
yticks([-25 -20:10:10]);
a1.YGrid = 'on';
xlabel('Atmospheric CO_2 concentration (ppm)');
ylabel('NBP (GtC/year)');

% legend
ll = legend([pp1, ss_trop, pp2, ss_bore], ...
    {'Tropical NBP in CESM historical & SSP1-2.6', ...
    'Tropical NBP (after CDR)', ...
    'Boreal NBP in CESM historical & SSP1-2.6' , ...
    'Boreal NBP (after CDR)'
    });
ll.Color = 'none';
ll.EdgeColor = 'none';
ll.Location = 'southeast';
ll.FontSize = 11;

% title
% tt = title('(a)','FontSize',12);
tt = title('A','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';

%% subplot 2

a2 = subplot(2,1,2);
p0 = line([0 440],[0 0],'Color',[0.7 0.7 0.7],'LineWidth',1);
hold on;

% area
[~, aa_hist1, aa_hist2] = anomaly(co2_sorted,hist_NBP(co2_I,1),'color','none','top',[34 200 0]/255,'bottom','none');
[~, aa_cdr1, aa_cdr2] = anomaly(CO2_2100_ts_y(sort_index_cdr,1),NBP_2100_ts_y(sort_index_cdr,1),'color','none','top','none','bottom',[154 99 235]/255);
aa_hist1.FaceAlpha = 0.5;   % hist1 is positive
aa_cdr2.FaceAlpha = 0.5;    % cdr2 is negative
pp_GCB = plot(co2_sorted,hist_NBP(co2_I,1),'Color',[0.1 0.1 0.1],'LineWidth',0.7);

% line
pp = plot(co2_sorted,cesm_NBP_ts(co2_I,1),'Color',[0.6 0.6 0.6],'LineWidth',0.7);

% scatter: CDR
ss1 = scatter(CO2_2100_ts_y,NBP_2100_ts_y,'filled');
ss1.MarkerEdgeColor = 'none';
ss1.MarkerFaceColor = [154 99 235]/255;
ss1.MarkerFaceAlpha = 0.8;
ss1.SizeData = 10;

% other setting
xlim([280 430]);
ylim([-12 4]);
yticks(-12:4:4);
a2.YGrid = 'on';
xlabel('Atmospheric CO_2 concentration (ppm)');
ylabel('NBP (GtC/year)');

% legend
ll = legend([pp_GCB, pp, ss1, aa_hist1, aa_cdr2], ...
    {'Global carbon project', ...
    'CESM historical & SSP1-2.6', ...
    'NBP during 2024-2100 (after CDR)' , ...
    'C uptake (till 2022): 64 GtC', ...
    'C release (after CDR): 54.2 GtC'   
    });
ll.Color = 'none';
ll.EdgeColor = 'none';
ll.Location = 'southeast';
ll.FontSize = 11;

% title
tt = title('B','FontSize',13,'FontWeight','bold');
tt.Units = 'Normalize';
tt.Position(1) = 0;
tt.HorizontalAlignment = 'left';












