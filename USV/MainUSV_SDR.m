%% Main USV SDR 
% SDR change during USV call period 

clear
experiments = get_experiment_redux;
experiments = experiments([256:301 303 306 309 312 315 318 321 324:420]);  % 256:380 [300 301 324:399]
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
    pre5_accstr(exp_idx) = nanmedian((USVSDR.SDRpre5_accstr(:, 1) - USVSDR.SDRpre5_accstr(:, 2)) ./ (USVSDR.SDRpre5_accstr(:, 1) + USVSDR.SDRpre5_accstr(:, 2)));
    pre5_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre5_accstr(:, 1) - USVSDR.SDRpre5_accstr(:, 2)) ./ (USVSDR.SDRpre5_accstr(:, 1) + USVSDR.SDRpre5_accstr(:, 2))); 
    pre5_accth(exp_idx) = nanmedian((USVSDR.SDRpre5_accth(:, 1) - USVSDR.SDRpre5_accth(:, 2)) ./ (USVSDR.SDRpre5_accth(:, 1) + USVSDR.SDRpre5_accth(:, 2)));
    pre5_accth_std(exp_idx) = nanstd((USVSDR.SDRpre5_accth(:, 1) - USVSDR.SDRpre5_accth(:, 2)) ./ (USVSDR.SDRpre5_accth(:, 1) + USVSDR.SDRpre5_accth(:, 2)));

    pre3_accstr(exp_idx) = nanmedian((USVSDR.SDRpre3_accstr(:, 1) - USVSDR.SDRpre3_accstr(:, 2)) ./ (USVSDR.SDRpre3_accstr(:, 1) + USVSDR.SDRpre3_accstr(:, 2)));
    pre3_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre3_accstr(:, 1) - USVSDR.SDRpre3_accstr(:, 2)) ./ (USVSDR.SDRpre3_accstr(:, 1) + USVSDR.SDRpre3_accstr(:, 2))); 
    pre3_accth(exp_idx) = nanmedian((USVSDR.SDRpre3_accth(:, 1) - USVSDR.SDRpre3_accth(:, 2)) ./ (USVSDR.SDRpre3_accth(:, 1) + USVSDR.SDRpre3_accth(:, 2)));
    pre3_accth_std(exp_idx) = nanstd((USVSDR.SDRpre3_accth(:, 1) - USVSDR.SDRpre3_accth(:, 2)) ./ (USVSDR.SDRpre3_accth(:, 1) + USVSDR.SDRpre3_accth(:, 2)));

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
% figure; hold on; 
% violins = violinplot([pre5_accstr; pre3_accstr; pre_accstr; during_accstr; post_accstr]'); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('normalized SDR'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% title('USV SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% yline(0, ':k','Linewidth', 1.2); 
% plot([1.2,1.8], [pre5_accstr' pre3_accstr'], 'k', 'Linewidth', 0.7)
% plot([2.2,2.8], [pre3_accstr' pre_accstr'], 'k', 'Linewidth', 0.7)
% plot([3.2,3.8], [pre_accstr' during_accstr'], 'k', 'Linewidth', 0.7)
% plot([4.2,4.8], [during_accstr' post_accstr'], 'k', 'Linewidth', 0.7)
% stats 
sdr1 = [pre5_accstr; pre_accstr; during_accstr]'; 
for i = 1 : size(sdr1, 2)
    for j = 1 : size(sdr1, 2) 
        p1(i, j) = signrank(sdr1(:, i), sdr1(:, j)); 
    end 
end 
p1(logical(eye(size(p1)))) = NaN; 
p1bfc = p1 * (length(p1)*(length(p1) - 1)/2); % Bonferroni correction for multiple comparisons 
p1bfcsig = p1bfc; 
p1bfcsig(p1bfc > 0.05) = NaN; 
% figure according to Mattia 
figure; hold on; 
plot([1 2 3], [pre5_accstr; pre_accstr; during_accstr]', 'Color', [0.7 0.7 0.7]); box off; 
plot(nanmedian([pre5_accstr; pre_accstr; during_accstr]', 1), 'Color', [0.6350 0.0780 0.1840], 'Linewidth', 2)
xlim([0.75 3.25]); ylim([-0.7 0.9])
yline(0, ':k','Linewidth', 1.2); 
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
xticks([1 2 3]); xticklabels({'baseline', 'prep', 'during'});
yticks([-0.6 -0.3 0 0.3 0.6]); ylabel('normalized SDR');
title('USV SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% plot std 
figure; hold on; 
violins = violinplot([pre5_accstr_std; pre3_accstr_std; pre_accstr_std; during_accstr_std; post_accstr_std]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('STDEV of SDR within mouse'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR std: ACC \rightarrow DMS', 'FontWeight', 'Bold')

% plot acc thstr
figure; hold on; 
violins = violinplot([pre5_accth; pre3_accth; pre_accth; during_accth; post_accth]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('normalized SDR'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
plot([1.2,1.8], [pre5_accth' pre3_accth'], 'k', 'Linewidth', 0.7)
plot([2.2,2.8], [pre3_accth' pre_accth'], 'k', 'Linewidth', 0.7)
plot([3.2,3.8], [pre_accth' during_accth'], 'k', 'Linewidth', 0.7)
plot([4.2,4.8], [during_accth' post_accth'], 'k', 'Linewidth', 0.7)
yline(0, ':k','Linewidth', 1.2); 
% figure according to Mattia 
figure; hold on; 
plot([1 2 3], [pre5_accth; pre_accth; during_accth]', 'Color', [0.7 0.7 0.7]); box off; 
plot(nanmedian([pre5_accth; pre_accth; during_accth]', 1), 'Color', [0.6350 0.0780 0.1840], 'Linewidth', 2)
xlim([0.75 3.25]); ylim([-0.95 0.5])
yline(0, ':k','Linewidth', 1.2); 
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
xticks([1 2 3]); xticklabels({'baseline', 'prep', 'during'});
yticks([-0.9 -0.6 -0.3 0 0.3]); ylabel('normalized SDR');
title('USV SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
% plot std 
figure; hold on; 
violins = violinplot([pre5_accth_std; pre3_accth_std; pre_accth_std; during_accth_std; post_accth_std]'); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
ylabel('STDEV of SDR within mouse'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
title('USV SDR std: ACC \rightarrow MD', 'FontWeight', 'Bold')
% stats 
sdr2 = [pre5_accth;  pre_accth; during_accth]'; 
for i = 1 : size(sdr2, 2)
    for j = 1 : size(sdr2, 2) 
        p2(i, j) = signrank(sdr2(:, i), sdr2(:, j)); 
    end 
end 
p2(logical(eye(size(p2)))) = NaN; 
p2bfc = p2 * (length(p2)*(length(p2) -1)/2); % Bonferroni correction for multiple comparisons 
p2bfcsig = p2bfc; 
p2bfcsig(p2bfc > 0.05) = NaN; 

