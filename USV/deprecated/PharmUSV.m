%% dataframe with every call in it 

clear 
L1 = readtable('Q:\Personal\Tony\Analysis\Experiments_PharmUSV.xlsx');
folder4stats = 'Q:\Personal\Tony\Analysis\Results_USV\Stats\';
folder4output = 'Q:\Personal\Tony\Analysis\Results_USV\'; 
L1 = L1(L1.exp_L == 1 & L1.exp_R == 1,:);
L1.exp_L = []; 
L1.exp_R = []; 
% L1 = L1(1:12, :);

calltot = []; 

for i = 1 : height(L1)
    stats = readtable([folder4stats L1.file{i} '_Stats.xlsx']);
    load([folder4output L1.file{i}]);
    Calls = Calls(Calls.Accept, :);

    % get features
    mouse = repmat(L1.mouse(i), [size(stats, 1) 1]);
    age = repmat(L1.age(i), [size(stats, 1) 1]);
    C21 = repmat(L1.C21(i), [size(stats, 1) 1]);
    length = Calls.Box(:, 3); 
    lowfreq = Calls.Box(:, 2); 
    highfreq = Calls.Box(:, 2) + Calls.Box(:, 4); 
    freqrange = Calls.Box(:, 4); 
    type = double(string(Calls.Type)); 
    temp = [table(mouse) table(age) table(C21) table(type, length, lowfreq, highfreq, freqrange) stats(:, [18 14 15 16]) stats(:, 1)]; %% update code for new stats output 
    % add to total variable
    calltot = [calltot; temp];
end 

% calltot.Label = double(string(cell2mat(calltot.Label))); 
% calltot = removevars(calltot, {'Score', 'BeginTime_s_', 'EndTime_s_'});

% % fix some empty cell display 
% for i = 1 : size(L1, 1) 
%     for j = 6 : size(L1, 2)
%         if strcmp(L1{i,j}, {'zeros(0,1)'}) 
%             L1{i,j} = {'[]'}; 
%         end 
%     end 
% end 

writetable(calltot, 'Q:\Personal\Tony\Analysis\USV_csvs\PharmUSV_allcalls.csv', 'QuoteStrings', true);
test = readtable('Q:\Personal\Tony\Analysis\USV_csvs\PharmUSV_allcalls.csv', 'Delimiter', ',');


%% 
% clear 
% L1 = readtable ('Q:\Personal\Tony\Analysis\PharmUSV.xlsx');
% folder = 'Q:\Personal\Tony\Analysis\Results_USV\';
% L1 = L1(L1.exp_L == 1 & L1.exp_R == 1,:);
% W1 = unstack(L1(:, [1 2 3]), L1.Properties.VariableNames([3]), 'age');
% 
% 
% sum(L1.age == 11 & L1.C21 == 1)
% sum(L1.age == 12 & L1.C21 == 1)
% 
% for i = 1 : height(L1)
%     if ~isempty(L1.file{i})
%         load([folder L1.file{i} '.mat'])
%         L1.callnum(i) = sum(Calls.Accept);
%         L1.score(i) = sum(double(Calls.Type(Calls.Accept)) - 1) / sum(Calls.Accept);
%         weight = Calls.Box(:, 3) .* Calls.Box(:, 4); 
%         weight = weight(Calls.Accept);
%         L1.weightedscore(i) = sum((double(Calls.Type(Calls.Accept)) - 1) .* weight) / sum(weight);
%         L1.perc1(i) = sum(Calls.Type == categorical(1)) / sum(Calls.Accept);
%         L1.perc2(i) = sum(Calls.Type == categorical(2)) / sum(Calls.Accept);
%         L1.perc3(i) = sum(Calls.Type == categorical(3)) / sum(Calls.Accept);
%     else 
%         L1.callnum(i) = 0;
%         L1.score(i) = NaN; 
%         L1.weightedscore(i) = NaN; 
%         L1.perc1(i) = NaN; 
%         L1.perc2(i) = NaN; 
%         L1.perc3(i) = NaN; 
%     end 
% end
% 
% L2 = L1(:, {'mouse', 'C21', 'callnum'});
% W1 = unstack(L2, "callnum", 'C21');
% for i = 1: height(W1) 
%     W2(i).mouse = W1.mouse(i); 
%     W2(i).before =  W1.x0(i) / (W1.x0(i) + W1.x1(i));
%     W2(i).after = W1.x1(i) / (W1.x1(i) + W1.x0(i));
% end 
% 
% figure; 
% plot([0 1], [W1.x0 + 1, W1.x1 + 1], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'before C21', 'after C21'})
% ylabel('Number of calls')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% set(gca, 'YScale', 'log')
% 
% figure; 
% plot([0 1], [W2.before; W2.after]', 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'before C21', 'after C21'})
% ylabel('Fraction of total calls')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% 
% L3.file = []; 
% L3.C21 = []; 
% W3 = unstack(L3, 'callnum', 'age')
% figure; 
% plot([0 1], [W3.x11, W3.x12], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'P11', 'P12'})
% ylabel('Number of calls')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% 
% figure; 
% plot([0 1], [W3.x11 ./ (W3.x11 + W3.x12), W3.x12 ./ (W3.x11 + W3.x12)], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'P11', 'P12'})
% ylabel('Fraction of total calls')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% 
% L5 = L1(:, {'mouse', 'score', 'weightedscore', 'C21'}); 
% W5 = unstack(L5, {'score', 'weightedscore'}, 'C21', 'VariableNamingRule', 'preserve');
% figure; 
% plot([0 1], [W5.score_0, W5.score_1], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'before C21', 'after C21'})
% ylabel('mean score')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% figure; 
% plot([0 1], [W5.weightedscore_0, W5.weightedscore_1], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 1.5])
% xticks([0 1]); xticklabels({'before C21', 'after C21'})
% ylabel('mean weighted score')
% set(gca, 'FontName', 'Arial', 'FontSize', 16)
% 
% L6 = L1(:, {'mouse', 'C21', 'perc1', 'perc2', 'perc3'});
% W6 = unstack(L6, {'perc1', 'perc2', 'perc3'}, 'C21', 'VariableNamingRule', 'preserve');
% figure; 
% plot([0 1], [W6.perc1_0, W6.perc1_1], 'LineWidth', 2, 'Color', 'k'); hold on; 
% plot([2 3], [W6.perc2_0, W6.perc2_1], 'LineWidth', 2, 'Color', 'k')
% plot([4 5], [W6.perc3_0, W6.perc3_1], 'LineWidth', 2, 'Color', 'k')
% xlim([-0.5 5.5])
% xticks([0 1 2 3 4 5 ]); xticklabels({'simple before', 'simple after','mid before', 'mid after','complex before', 'complex after'})
% ylabel('percentage')
% set(gca, 'FontName', 'Arial', 'FontSize', 16, 'TickDir', 'out')


%% different features 
% 
% clear 
% L1 = readtable('Q:\Personal\Tony\Analysis\PharmUSV.xlsx');
% folder4stats = 'Q:\Personal\Tony\Analysis\Results_USV\Stats\';
% folder4output = 'Q:\Personal\Tony\Analysis\Results_USV\'; 
% L1 = L1(L1.exp_L == 1 & L1.exp_R == 1,:);
% L1.exp_L = []; 
% L1.exp_R = []; 
% % L1 = L1(1:12, :);
% 
% for i = 1 : height(L1)
%     stats = readtable([folder4stats L1.file{i} '_Stats.xlsx']);
%     load([folder4output L1.file{i}]);
%     Calls = Calls(Calls.Accept, :);
%     % fill in data frame 
%     L1.callnum(i) = sum(stats.Accepted);
%     L1.length(i) = mean(Calls.Box(:, 3)); 
%     L1.length_std(i) = std(Calls.Box(:, 3));
% %     L1.principlefreq(i) = mean(stats.PrincipalFrequency_kHz_); 
% %     L1.principlefreq_std(i) = std(stats.PrincipalFrequency_kHz_);
%     L1.lowfreq(i) = mean(Calls.Box(:, 2));
%     L1.lowfreq_std(i) = std(Calls.Box(:, 2));
%     L1.highfreq(i) = mean(Calls.Box(:, 2) + Calls.Box(:, 4)); 
%     L1.highfreq_std(i) = std(Calls.Box(:, 2) + Calls.Box(:, 4));
%     L1.deltafreq(i) = mean(Calls.Box(:, 4)); 
%     L1.deltafreq_std(i) = std(Calls.Box(:, 4)); 
%     L1.peakfreq(i) = mean(stats.PeakFreq_kHz_); 
%     L1.peakfreq_std(i) = std(stats.PeakFreq_kHz_); 
% %     L1.freqstd(i) = mean(stats.FrequencyStandardDeviation_kHz_); 
% %     L1.freqstd_std(i) = std(stats.FrequencyStandardDeviation_kHz_); 
%     L1.meanpower(i) = mean(stats.MeanPower_dB_Hz_); 
%     L1.meanpower_std(i) = std(stats.MeanPower_dB_Hz_); 
%     L1.slope(i) = mean(stats.Slope_kHz_s_); 
%     L1.slope_std(i) = std(stats.Slope_kHz_s_); 
%     L1.sinuosity(i) = mean(stats.Sinuosity); 
%     L1.sinuosity_std(i) = std(stats.Sinuosity); 
%     L1.tonality(i) = mean(stats.Tonality); 
%     L1.tonality_std(i) = std(stats.Tonality); 
% end
% L1.file = []; 
% L1.age = []; 
% % make it into wide format
% W1 = unstack(L1, L1.Properties.VariableNames([3:end]), 'C21', 'VariableNamingRule', 'preserve');
% 
% % call num 
% figure; violins = violinplot([W1.callnum_0 W1.callnum_1] + 1);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.callnum_0 W1.callnum_1] + 1, 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('# of calls'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% % set(gca, 'YScale', 'log')
% [p, ~] = signrank(W1.callnum_0, W1.callnum_1); 
% title(['p = ' num2str(p)])
% 
% % call length
% figure; violins = violinplot([W1.length_0 W1.length_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.length_0 W1.length_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('call length (s)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.length_0, W1.length_1); 
% title(['p = ' num2str(p)])
% % call length std
% figure; violins = violinplot([W1.length_std_0 W1.length_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.length_std_0 W1.length_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('call length std (s)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.length_std_0, W1.length_std_1); 
% title(['p = ' num2str(p)])
% 
% % % principle freq
% % figure; violins = violinplot([W1.principlefreq_0 W1.principlefreq_1]);
% % for idx = 1:size(violins, 2)
% %     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
% %     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% % end
% % plot([1.3 1.7], [W1.principlefreq_0 W1.principlefreq_1], 'Color', 'k', 'LineWidth', 2);
% % xticklabels({'before C21', 'after C21'}); 
% % ylabel('Principle Freq (kHz)'); 
% % set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% % [p, ~] = signrank(W1.principlefreq_0, W1.principlefreq_1); 
% % title(['p = ' num2str(p)])
% % % principle freq std
% % figure; violins = violinplot([W1.principlefreq_std_0 W1.principlefreq_std_1]);
% % for idx = 1:size(violins, 2)
% %     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
% %     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% % end
% % plot([1.3 1.7], [W1.principlefreq_std_0 W1.principlefreq_std_1], 'Color', 'k', 'LineWidth', 2);
% % xticklabels({'before C21', 'after C21'}); 
% % ylabel('Principle Freq std (kHz)'); 
% % set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% % [p, ~] = signrank(W1.principlefreq_std_0, W1.principlefreq_std_1); 
% % title(['p = ' num2str(p)])
% 
% % Low freq
% figure; violins = violinplot([W1.lowfreq_0 W1.lowfreq_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.lowfreq_0 W1.lowfreq_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Low Freq (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.lowfreq_0, W1.lowfreq_1); 
% title(['p = ' num2str(p)])
% % low freq std
% figure; violins = violinplot([W1.lowfreq_std_0 W1.lowfreq_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.lowfreq_std_0 W1.lowfreq_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Low Freq std (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.lowfreq_std_0, W1.lowfreq_std_1); 
% title(['p = ' num2str(p)])
% 
% % High freq
% figure; violins = violinplot([W1.highfreq_0 W1.highfreq_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.highfreq_0 W1.highfreq_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('High Freq (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.highfreq_0, W1.highfreq_1); 
% title(['p = ' num2str(p)])
% % High freq std
% figure; violins = violinplot([W1.highfreq_std_0 W1.highfreq_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.highfreq_std_0 W1.highfreq_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('High Freq std (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.highfreq_std_0, W1.highfreq_std_1); 
% title(['p = ' num2str(p)])
% 
% % peak freq
% figure; violins = violinplot([W1.peakfreq_0 W1.peakfreq_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.peakfreq_0 W1.peakfreq_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Peak Freq (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.peakfreq_0, W1.peakfreq_1); 
% title(['p = ' num2str(p)])
% % peak freq std
% figure; violins = violinplot([W1.peakfreq_std_0 W1.peakfreq_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.peakfreq_std_0 W1.peakfreq_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Peak Freq std (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.peakfreq_std_0, W1.peakfreq_std_1); 
% title(['p = ' num2str(p)])
% 
% % freq range
% figure; violins = violinplot([W1.deltafreq_0 W1.deltafreq_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.deltafreq_0 W1.deltafreq_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Freq Range (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.deltafreq_0, W1.deltafreq_1); 
% title(['p = ' num2str(p)])
% % freq range std
% figure; violins = violinplot([W1.deltafreq_std_0 W1.deltafreq_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.deltafreq_std_0 W1.deltafreq_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Freq Range std (kHz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.deltafreq_std_0, W1.deltafreq_std_1); 
% title(['p = ' num2str(p)])
% 
% % % freq STD
% % figure; violins = violinplot([W1.freqstd_0 W1.freqstd_1]);
% % for idx = 1:size(violins, 2)
% %     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
% %     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% % end
% % plot([1.3 1.7], [W1.freqstd_0 W1.freqstd_1], 'Color', 'k', 'LineWidth', 2);
% % xticklabels({'before C21', 'after C21'}); 
% % ylabel('Freq STD (kHz)'); 
% % set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% % [p, ~] = signrank(W1.freqstd_0, W1.freqstd_1); 
% % title(['p = ' num2str(p)])
% % % freq range std
% % figure; violins = violinplot([W1.freqstd_std_0 W1.freqstd_std_1]);
% % for idx = 1:size(violins, 2)
% %     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
% %     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% % end
% % plot([1.3 1.7], [W1.freqstd_std_0 W1.freqstd_std_1], 'Color', 'k', 'LineWidth', 2);
% % xticklabels({'before C21', 'after C21'}); 
% % ylabel('Freq STD std (kHz)'); 
% % set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% % [p, ~] = signrank(W1.freqstd_std_0, W1.freqstd_std_1); 
% % title(['p = ' num2str(p)])
% 
% % mean power
% figure; violins = violinplot([W1.meanpower_0 W1.meanpower_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.meanpower_0 W1.meanpower_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('mean power (dB/Hz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.meanpower_0, W1.meanpower_1); 
% title(['p = ' num2str(p)])
% % mean power std
% figure; violins = violinplot([W1.meanpower_std_0 W1.meanpower_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.meanpower_std_0 W1.meanpower_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('mean power std (dB/Hz)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.meanpower_std_0, W1.meanpower_std_1); 
% title(['p = ' num2str(p)])
% 
% % slope
% figure; violins = violinplot([W1.slope_0 W1.slope_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.slope_0 W1.slope_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Slope (Hz/s)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.slope_0, W1.slope_1); 
% title(['p = ' num2str(p)])
% % slope std
% figure; violins = violinplot([W1.slope_std_0 W1.slope_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.slope_std_0 W1.slope_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Slope std (Hz/s)'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.slope_std_0, W1.slope_std_1); 
% title(['p = ' num2str(p)])
% 
% % sinuosity
% figure; violins = violinplot([W1.sinuosity_0 W1.sinuosity_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.sinuosity_0 W1.sinuosity_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Sinuosity'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.sinuosity_0, W1.sinuosity_1); 
% title(['p = ' num2str(p)])
% % sinuosity std
% figure; violins = violinplot([W1.sinuosity_std_0 W1.sinuosity_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.sinuosity_std_0 W1.sinuosity_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Sinuosity std'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.sinuosity_std_0, W1.sinuosity_std_1); 
% title(['p = ' num2str(p)])
% 
% % tonality
% figure; violins = violinplot([W1.tonality_0 W1.tonality_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.tonality_0 W1.tonality_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Tonality'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.tonality_0, W1.tonality_1); 
% title(['p = ' num2str(p)])
% % tonality std
% figure; violins = violinplot([W1.tonality_std_0 W1.tonality_std_1]);
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% plot([1.3 1.7], [W1.tonality_std_0 W1.tonality_std_1], 'Color', 'k', 'LineWidth', 2);
% xticklabels({'before C21', 'after C21'}); 
% ylabel('Tonality std'); 
% set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
% [p, ~] = signrank(W1.tonality_std_0, W1.tonality_std_1); 
% title(['p = ' num2str(p)])
% 


