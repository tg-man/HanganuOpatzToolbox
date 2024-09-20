%% Main USV SDR 
% SDR change during USV call period 

clear
experiments = get_experiment_redux;
experiments = experiments([256:301 324:420]);  % 256:380 [300 301 324:399]
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4USVpower = 'Q:\Personal\Tony\Analysis\Results_USVpower\'; 
folder4USVSDR = 'Q:\Personal\Tony\Analysis\Results_USVSDR\';

params.ch_acc = 17 : 32; 
params.ch_str = 1 : 16; 
params.ch_th = 33 : 48; 
params.minusvnum = 5; 

[~, enoughUSV] = getUSVSDR(experiments, folder4USVpower, folder4USVSDR, params);

%% plotting 

experiments = experiments(enoughUSV); 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    % load data and calculate plotting values 
    load([folder4USVSDR experiment.animal_ID]);
    pre_accstr(exp_idx) = nanmedian((USVSDR.SDRpre_accstr(:, 1) - USVSDR.SDRpre_accstr(:, 2)) ./ (USVSDR.SDRpre_accstr(:, 1) + USVSDR.SDRpre_accstr(:, 2)));
    pre_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre_accstr(:, 1) - USVSDR.SDRpre_accstr(:, 2)) ./ (USVSDR.SDRpre_accstr(:, 1) + USVSDR.SDRpre_accstr(:, 2))); 
    pre_accth(exp_idx) = nanmedian((USVSDR.SDRpre_accth(:, 1) - USVSDR.SDRpre_accth(:, 2)) ./ (USVSDR.SDRpre_accth(:, 1) + USVSDR.SDRpre_accth(:, 2)));
    pre_accth_std(exp_idx) = nanstd((USVSDR.SDRpre_accth(:, 1) - USVSDR.SDRpre_accth(:, 2)) ./ (USVSDR.SDRpre_accth(:, 1) + USVSDR.SDRpre_accth(:, 2)));

    during_accstr(exp_idx) = nanmedian((USVSDR.SDRduring_accstr(:, 1) - USVSDR.SDRduring_accstr(:, 2)) ./ (USVSDR.SDRduring_accstr(:, 1) + USVSDR.SDRduring_accstr(:, 2)));
    during_accstr_std(exp_idx) = nanstd((USVSDR.SDRduring_accstr(:, 1) - USVSDR.SDRduring_accstr(:, 2)) ./ (USVSDR.SDRduring_accstr(:, 1) + USVSDR.SDRduring_accstr(:, 2)));
    during_accth(exp_idx) = nanmedian((USVSDR.SDRduring_accth(:, 1) - USVSDR.SDRduring_accth(:, 2)) ./ (USVSDR.SDRduring_accth(:, 1) + USVSDR.SDRduring_accth(:, 2)));
    during_accth_std(exp_idx) = nanstd((USVSDR.SDRduring_accth(:, 1) - USVSDR.SDRduring_accth(:, 2)) ./ (USVSDR.SDRduring_accth(:, 1) + USVSDR.SDRduring_accth(:, 2)));

    post_accstr(exp_idx) = nanmedian((USVSDR.SDRpost_accstr(:, 1) - USVSDR.SDRpost_accstr(:, 2)) ./ (USVSDR.SDRpost_accstr(:, 1) + USVSDR.SDRpost_accstr(:, 2)));
    post_accstr_std(exp_idx) = nanstd((USVSDR.SDRpost_accstr(:, 1) - USVSDR.SDRpost_accstr(:, 2)) ./ (USVSDR.SDRpost_accstr(:, 1) + USVSDR.SDRpost_accstr(:, 2)));
    post_accth(exp_idx) = nanmedian((USVSDR.SDRpost_accth(:, 1) - USVSDR.SDRpost_accth(:, 2)) ./ (USVSDR.SDRpost_accth(:, 1) + USVSDR.SDRpost_accth(:, 2)));
    post_accth_std(exp_idx) = nanstd((USVSDR.SDRpost_accth(:, 1) - USVSDR.SDRpost_accth(:, 2)) ./ (USVSDR.SDRpost_accth(:, 1) + USVSDR.SDRpost_accth(:, 2)));
end 
% in during std, replace 0 with NaN for plotting 
during_accstr_std(during_accstr_std == 0) = NaN; 
during_accth_std(during_accth_std == 0) = NaN; 

% plot acc str
figure; hold on; 
violins = violinplot([pre_accstr; during_accstr; post_accstr]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
plot([1.2,1.8], [pre_accstr' during_accstr'], 'k', 'Linewidth', 1.2)
plot([2.2,2.8], [during_accstr' post_accstr'], 'k', 'Linewidth', 1.2)
yline(0, ':k','Linewidth', 1.2); 
% stats 
[p1, h1] = signrank(pre_accstr, during_accstr); 
[p2, h2] = signrank(during_accstr, post_accstr); 
disp([p1 p2]); 
% plot std 
figure; hold on; 
violins = violinplot([pre_accstr_std; during_accstr_std; post_accstr_std]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('STDEV of SDR within mouse'); xticklabels({'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR std: ACC \rightarrow DMS', 'FontWeight', 'Bold')


% plot acc thstr
figure; hold on; 
violins = violinplot([pre_accth; during_accth; post_accth]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
plot([1.2,1.8], [pre_accth' during_accth'], 'k', 'Linewidth', 1.2)
plot([2.2,2.8], [during_accth' post_accth'], 'k', 'Linewidth', 1.2)
yline(0, ':k','Linewidth', 1.2); 
% stats 
[p3, h3] = signrank(pre_accth, during_accth); 
[p4, h4] = signrank(during_accth, post_accth); 
disp([p3 p4]); 
% plot std 
figure; hold on; 
violins = violinplot([pre_accth_std; during_accth_std; post_accth_std]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('STDEV of SDR within mouse'); xticklabels({'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR std: ACC \rightarrow MD', 'FontWeight', 'Bold')

