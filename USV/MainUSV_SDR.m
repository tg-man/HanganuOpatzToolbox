%% Main USV SDR 
% SDR change during USV call period 

clear
% load table with all USV sentences 
filename = 'Q:/Personal/Tony/Analysis/USV_csvs/ephysUSV_sentence_features_1s.csv';
opts = detectImportOptions(filename, 'Delimiter', ',');
opts = setvartype(opts, "sentence", "string");
T = readtable(filename, opts);

% get rid of opto sessions 
T = T(strcmp(T.condition, 'baseline'), :); 
% get rid of single calls 
T = T(T.length > 1, :); 

% inter sentence interval 
ISI = 5000; 

% all animals 
animals = unique(T.mouse); 

% select experiments 
experiments = get_experiment_redux;
experiments = experiments(contains({experiments.animal_ID}, animals)); 
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only')); 

% links 
folder4USVpower = 'Q:\Personal\Tony\Analysis\Results_USVpower_noisocall_clickrelease\'; 
folder4USVSDR = 'Q:\Personal\Tony\Analysis\Results_USVSDR_noisocall_clickrelease\';

% function params 
params.ch_acc = 17 : 32; 
params.ch_str = 1 : 16; 
params.ch_th = 33 : 48; 

[~] = getUSVSDR(experiments, folder4USVpower, folder4USVSDR, params);

%% plotting section 

% initalize some table 
sdr_sentence = table(); 
sdr_mouse = table(); 

for mouse_idx = 1 : numel(animals)
    mouse = animals{mouse_idx};
    
    % filter sentences for this animal 
    T_mouse = T(strcmp(T.mouse, mouse), :);
    % in case two neighboring sentences are too close, delete 2nd one 
    % interval between previous event end and next event start
    gap = T_mouse.stop(2:end) - T_mouse.start(1:end-1);
    % delete the NEXT event if it starts too soon after the previous event
    deleteIdx = [false; gap < ISI];
    T_mouse = T_mouse(~deleteIdx, :);

    % if the first call starts too early, drop 
    if T_mouse.start(1) < ISI
        T_mouse(1, :) = []; 
    end 

    % load USV SDR file 
    load([folder4USVSDR mouse])

    % extract baseline SDR, only include baseline recordings 
    baseline = USVSDR.SDRbaseline_accstr(strcmp(T_mouse.condition, 'baseline'), :); 
    % normalize 
    baseline = (baseline(:, 1) - baseline(:, 2)) ./ (baseline(:, 1) + baseline(:, 2)); 

    % extract prep SDR, only include baseline recordings 
    prep = USVSDR.SDRprep_accstr(strcmp(T_mouse.condition, 'baseline'), :); 
    % normalize 
    prep = (prep(:, 1) - prep(:, 2)) ./ (prep(:, 1) + prep(:, 2)); 

    % extract during SDR, only include baseline recordings 
    during = USVSDR.SDRduring_accstr(strcmp(T_mouse.condition, 'baseline'), :); 
    % normalize 
    during = (during(:, 1) - during(:, 2)) ./ (during(:, 1) + during(:, 2)); 
    
    % put into a table 
    temp = table(); 
    temp.mouse = repmat({mouse}, [numel(baseline) 1]); 
    temp.baseline = baseline; 
    temp.prep = prep; 
    temp.during = during; 
    % add to sum table 
    sdr_sentence = [sdr_sentence; temp]; 
    clearvars temp 

    % now do the mouse average table 
    sdr_mouse.mouse(mouse_idx) = {mouse}; 
    sdr_mouse.baseline(mouse_idx) = nanmedian(baseline); 
    sdr_mouse.prep(mouse_idx) = nanmedian(prep); 
    sdr_mouse.during(mouse_idx) = nanmedian(during); 

    clearvars baseline prep during
end 


figure; hold on
plot([1.1 1.9], [sdr_mouse.baseline sdr_mouse.prep], 'Color', [0.7 0.7 0.7], 'LineWidth', 1)
plot([2.1 2.9], [sdr_mouse.prep sdr_mouse.during], 'Color', [0.7 0.7 0.7], 'LineWidth', 1)
% plot([1 2], nanmean([sdr_mouse.baseline sdr_mouse.prep]), 'Color', 'b', 'LineWidth', 2) 
% plot([2 3], nanmean([sdr_mouse.prep sdr_mouse.during]), 'Color', 'b', 'LineWidth', 2)
yline(0, '--', 'LineWidth', 1.5)
ylim([-1 1])
xlim([0.5 3.5])
% violin plot 
violins = violinplot(sdr_mouse(:, {'baseline', 'prep', 'during'}), {'Baseline', 'Prep', 'During'}, 'Width', 0.2, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0], 'ViolinAlpha', 0.8);
for idx = 1 : size(violins, 2)
%     violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 0; 
end
ifn = viridis; 
violins(1).ViolinColor = ifn(100, :);
violins(3).ViolinColor = ifn(100, :);
violins(2).ViolinColor = ifn(230, :);
xticklabels({'Baseline', 'Prep', 'During'}); 
ylabel('Normalized SDR');
set(gca, 'TickDir', 'out', 'FontSize', 20, 'FontName', 'Arial', 'LineWidth', 2); 


% Stats on mouse average data
% define the within-subject factor
withinDesign = table(categorical(["baseline"; "prep"; "during"]), 'VariableNames', {'phase'});
% repeated-measures model
rm = fitrm(sdr_mouse, 'baseline-during ~ 1', 'WithinDesign', withinDesign);
% overall repeated-measures ANOVA
ranovatbl = ranova(rm, 'WithinModel', 'phase')
pairwise = multcompare(rm, 'phase')

% save sentence sdr table for R 
sdr_long = stack(sdr_sentence, {'baseline', 'prep', 'during'}, 'NewDataVariableName', 'SDR', 'IndexVariableName', 'phase');
writetable(sdr_long, [folder4USVSDR, 'USVSDR_sentence.csv'], 'QuoteStrings', true);



% violin plot 
% figure; 
% violinplot(sdr_sentence(:, {'baseline', 'prep', 'during'}))
% yline(0, '--', 'LineWidth', 1.5)

% % old deprecated plotting script 
% %% plotting 
% 
% experiments = experiments(enoughUSV); 
% 
% for exp_idx = 1 : size(experiments, 2) 
%     experiment = experiments(exp_idx); 
%     % load data and calculate plotting values 
%     load([folder4USVSDR experiment.animal_ID]);
%     pre5_accstr(exp_idx) = nanmedian((USVSDR.SDRpre5_accstr(:, 1) - USVSDR.SDRpre5_accstr(:, 2)) ./ (USVSDR.SDRpre5_accstr(:, 1) + USVSDR.SDRpre5_accstr(:, 2)));
%     pre5_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre5_accstr(:, 1) - USVSDR.SDRpre5_accstr(:, 2)) ./ (USVSDR.SDRpre5_accstr(:, 1) + USVSDR.SDRpre5_accstr(:, 2))); 
%     pre5_accth(exp_idx) = nanmedian((USVSDR.SDRpre5_accth(:, 1) - USVSDR.SDRpre5_accth(:, 2)) ./ (USVSDR.SDRpre5_accth(:, 1) + USVSDR.SDRpre5_accth(:, 2)));
%     pre5_accth_std(exp_idx) = nanstd((USVSDR.SDRpre5_accth(:, 1) - USVSDR.SDRpre5_accth(:, 2)) ./ (USVSDR.SDRpre5_accth(:, 1) + USVSDR.SDRpre5_accth(:, 2)));
% 
%     pre3_accstr(exp_idx) = nanmedian((USVSDR.SDRpre3_accstr(:, 1) - USVSDR.SDRpre3_accstr(:, 2)) ./ (USVSDR.SDRpre3_accstr(:, 1) + USVSDR.SDRpre3_accstr(:, 2)));
%     pre3_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre3_accstr(:, 1) - USVSDR.SDRpre3_accstr(:, 2)) ./ (USVSDR.SDRpre3_accstr(:, 1) + USVSDR.SDRpre3_accstr(:, 2))); 
%     pre3_accth(exp_idx) = nanmedian((USVSDR.SDRpre3_accth(:, 1) - USVSDR.SDRpre3_accth(:, 2)) ./ (USVSDR.SDRpre3_accth(:, 1) + USVSDR.SDRpre3_accth(:, 2)));
%     pre3_accth_std(exp_idx) = nanstd((USVSDR.SDRpre3_accth(:, 1) - USVSDR.SDRpre3_accth(:, 2)) ./ (USVSDR.SDRpre3_accth(:, 1) + USVSDR.SDRpre3_accth(:, 2)));
% 
%     pre_accstr(exp_idx) = nanmedian((USVSDR.SDRpre_accstr(:, 1) - USVSDR.SDRpre_accstr(:, 2)) ./ (USVSDR.SDRpre_accstr(:, 1) + USVSDR.SDRpre_accstr(:, 2)));
%     pre_accstr_std(exp_idx) = nanstd((USVSDR.SDRpre_accstr(:, 1) - USVSDR.SDRpre_accstr(:, 2)) ./ (USVSDR.SDRpre_accstr(:, 1) + USVSDR.SDRpre_accstr(:, 2))); 
%     pre_accth(exp_idx) = nanmedian((USVSDR.SDRpre_accth(:, 1) - USVSDR.SDRpre_accth(:, 2)) ./ (USVSDR.SDRpre_accth(:, 1) + USVSDR.SDRpre_accth(:, 2)));
%     pre_accth_std(exp_idx) = nanstd((USVSDR.SDRpre_accth(:, 1) - USVSDR.SDRpre_accth(:, 2)) ./ (USVSDR.SDRpre_accth(:, 1) + USVSDR.SDRpre_accth(:, 2)));
% 
%     during_accstr(exp_idx) = nanmedian((USVSDR.SDRduring_accstr(:, 1) - USVSDR.SDRduring_accstr(:, 2)) ./ (USVSDR.SDRduring_accstr(:, 1) + USVSDR.SDRduring_accstr(:, 2)));
%     during_accstr_std(exp_idx) = nanstd((USVSDR.SDRduring_accstr(:, 1) - USVSDR.SDRduring_accstr(:, 2)) ./ (USVSDR.SDRduring_accstr(:, 1) + USVSDR.SDRduring_accstr(:, 2)));
%     during_accth(exp_idx) = nanmedian((USVSDR.SDRduring_accth(:, 1) - USVSDR.SDRduring_accth(:, 2)) ./ (USVSDR.SDRduring_accth(:, 1) + USVSDR.SDRduring_accth(:, 2)));
%     during_accth_std(exp_idx) = nanstd((USVSDR.SDRduring_accth(:, 1) - USVSDR.SDRduring_accth(:, 2)) ./ (USVSDR.SDRduring_accth(:, 1) + USVSDR.SDRduring_accth(:, 2)));
% 
%     post_accstr(exp_idx) = nanmedian((USVSDR.SDRpost_accstr(:, 1) - USVSDR.SDRpost_accstr(:, 2)) ./ (USVSDR.SDRpost_accstr(:, 1) + USVSDR.SDRpost_accstr(:, 2)));
%     post_accstr_std(exp_idx) = nanstd((USVSDR.SDRpost_accstr(:, 1) - USVSDR.SDRpost_accstr(:, 2)) ./ (USVSDR.SDRpost_accstr(:, 1) + USVSDR.SDRpost_accstr(:, 2)));
%     post_accth(exp_idx) = nanmedian((USVSDR.SDRpost_accth(:, 1) - USVSDR.SDRpost_accth(:, 2)) ./ (USVSDR.SDRpost_accth(:, 1) + USVSDR.SDRpost_accth(:, 2)));
%     post_accth_std(exp_idx) = nanstd((USVSDR.SDRpost_accth(:, 1) - USVSDR.SDRpost_accth(:, 2)) ./ (USVSDR.SDRpost_accth(:, 1) + USVSDR.SDRpost_accth(:, 2)));
% end 
% % in during std, replace 0 with NaN for plotting 
% during_accstr_std(during_accstr_std == 0) = NaN; 
% during_accth_std(during_accth_std == 0) = NaN; 
% 
% % plot acc str
% % figure; hold on; 
% % violins = violinplot([pre5_accstr; pre3_accstr; pre_accstr; during_accstr; post_accstr]'); 
% % for idx = 1:size(violins, 2)
% %     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
% %     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% % end
% % ylabel('normalized SDR'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
% % set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% % title('USV SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% % yline(0, ':k','Linewidth', 1.2); 
% % plot([1.2,1.8], [pre5_accstr' pre3_accstr'], 'k', 'Linewidth', 0.7)
% % plot([2.2,2.8], [pre3_accstr' pre_accstr'], 'k', 'Linewidth', 0.7)
% % plot([3.2,3.8], [pre_accstr' during_accstr'], 'k', 'Linewidth', 0.7)
% % plot([4.2,4.8], [during_accstr' post_accstr'], 'k', 'Linewidth', 0.7)
% % stats 
% sdr1 = [pre5_accstr; pre_accstr; during_accstr]'; 
% for i = 1 : size(sdr1, 2)
%     for j = 1 : size(sdr1, 2) 
%         p1(i, j) = signrank(sdr1(:, i), sdr1(:, j)); 
%     end 
% end 
% p1(logical(eye(size(p1)))) = NaN; 
% p1bfc = p1 * (length(p1)*(length(p1) - 1)/2); % Bonferroni correction for multiple comparisons 
% p1bfcsig = p1bfc; 
% p1bfcsig(p1bfc > 0.05) = NaN; 
% % figure according to Mattia 
% figure; hold on; 
% plot([1 2 3], [pre5_accstr; pre_accstr; during_accstr]', 'Color', [0.7 0.7 0.7]); box off; 
% plot(nanmedian([pre5_accstr; pre_accstr; during_accstr]', 1), 'Color', [0.6350 0.0780 0.1840], 'Linewidth', 2)
% xlim([0.75 3.25]); ylim([-0.7 0.9])
% yline(0, ':k','Linewidth', 1.2); 
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% xticks([1 2 3]); xticklabels({'baseline', 'prep', 'during'});
% yticks([-0.6 -0.3 0 0.3 0.6]); ylabel('normalized SDR');
% title('USV SDR: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% % plot std 
% figure; hold on; 
% violins = violinplot([pre5_accstr_std; pre3_accstr_std; pre_accstr_std; during_accstr_std; post_accstr_std]'); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('STDEV of SDR within mouse'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% title('USV SDR std: ACC \rightarrow DMS', 'FontWeight', 'Bold')
% 
% % plot acc thstr
% figure; hold on; 
% violins = violinplot([pre5_accth; pre3_accth; pre_accth; during_accth; post_accth]'); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('normalized SDR'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% title('USV SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
% plot([1.2,1.8], [pre5_accth' pre3_accth'], 'k', 'Linewidth', 0.7)
% plot([2.2,2.8], [pre3_accth' pre_accth'], 'k', 'Linewidth', 0.7)
% plot([3.2,3.8], [pre_accth' during_accth'], 'k', 'Linewidth', 0.7)
% plot([4.2,4.8], [during_accth' post_accth'], 'k', 'Linewidth', 0.7)
% yline(0, ':k','Linewidth', 1.2); 
% % figure according to Mattia 
% figure; hold on; 
% plot([1 2 3], [pre5_accth; pre_accth; during_accth]', 'Color', [0.7 0.7 0.7]); box off; 
% plot(nanmedian([pre5_accth; pre_accth; during_accth]', 1), 'Color', [0.6350 0.0780 0.1840], 'Linewidth', 2)
% xlim([0.75 3.25]); ylim([-0.95 0.5])
% yline(0, ':k','Linewidth', 1.2); 
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% xticks([1 2 3]); xticklabels({'baseline', 'prep', 'during'});
% yticks([-0.9 -0.6 -0.3 0 0.3]); ylabel('normalized SDR');
% title('USV SDR: ACC \rightarrow MD', 'FontWeight', 'Bold')
% % plot std 
% figure; hold on; 
% violins = violinplot([pre5_accth_std; pre3_accth_std; pre_accth_std; during_accth_std; post_accth_std]'); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% ylabel('STDEV of SDR within mouse'); xticklabels({'pre5', 'pre3', 'pre','during', 'post'});
% set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
% title('USV SDR std: ACC \rightarrow MD', 'FontWeight', 'Bold')
% % stats 
% sdr2 = [pre5_accth;  pre_accth; during_accth]'; 
% for i = 1 : size(sdr2, 2)
%     for j = 1 : size(sdr2, 2) 
%         p2(i, j) = signrank(sdr2(:, i), sdr2(:, j)); 
%     end 
% end 
% p2(logical(eye(size(p2)))) = NaN; 
% p2bfc = p2 * (length(p2)*(length(p2) -1)/2); % Bonferroni correction for multiple comparisons 
% p2bfcsig = p2bfc; 
% p2bfcsig(p2bfc > 0.05) = NaN; 
% 
