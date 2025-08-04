%% USV power

clear
% get experiments 
experiments = get_experiment_redux;

% load table with all USV sentences 
T = readtable('Q:/Personal/Tony/Analysis/USV_csvs/ephysUSV_sentence_features.csv', 'Delimiter',','); 

% signal loading params 
sigparams.ch2load = 1:48; 
sigparams.cores = 3; 
sigparams.fs = 32000; % sampling rate from data
sigparams.downsampling_factor = 160; % downsample for LFP analysis
sigparams.low_cut = 1; 
sigparams.ExtractMode = 1; % extract from neuralynx into matlab
sigparams.length = 1; % signal length to for pre and post computation, in second

% pWelch params
psparams. windowSize = 1;
psparams. overlap = 0.4;
psparams. nfft = 256;
psparams. maxFreq = 100;

repeat_calc = 0;
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVpower\'; 

% get unique animal numbers 
animals = unique(T.mouse); 

% calculate one animal at a time 
for animal_idx = 1 : size(animals, 1) 
    tic
    disp(['computing animal ' num2str(animal_idx) ' / ' num2str(numel(animals))])
    % get animal number and all experiments for this animal 
    mouse = animals{animal_idx}; 
    T_mouse = T(strcmp(T.mouse, mouse), :); 
    experiments_mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), mouse)); 

    USVpower = getUSVpower(experiments_mouse, T_mouse, sigparams, psparams, repeat_calc, folder2save); 
    toc
end 


%% plotting 

baseline_acc = []; 
baseline_str = []; 

prep_acc = []; 
prep_str = []; 

during_acc = []; 
during_str = []; 

for animal_idx = 1 : size(animals, 1) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
    badch = rmmissing([experiments4mouse(1).NoisyCh experiments4mouse(1).OffCh]); 

    % grab number from file and get rid of bad channels  
    load([folder2save animal '.mat']);
    baseline = nanmean(USVpower.baseline, 3); 
    baseline(badch, :) = NaN; 
    during = nanmean(USVpower.during, 3); 
    during(badch, :) = NaN; 
    prep = nanmean(USVpower.prep, 3); 
    prep(badch, :) = NaN; 

    % get acc power average across trials 
    during_acc(animal_idx, :) = nanmedian(during(17:32, :));
    baseline_acc(animal_idx, :) = nanmedian(baseline(17:32, :)); 
    prep_acc(animal_idx, :) = nanmedian(prep(17:32, :)); 

    % get str power average across trials 
    if experiments4mouse(1).target2 == 1
        baseline_str(animal_idx, :) = nanmedian(baseline(1:16, :)); 
        prep_str(animal_idx, :) = nanmedian(prep(1:16, :)); 
        during_str(animal_idx, :) = nanmedian(during(1:16, :)); 
    else 
        baseline_str(animal_idx, :) = NaN; 
        prep_str(animal_idx, :) = NaN; 
        during_str(animal_idx, :) = NaN; 
    end 
%     if experiments4mouse(1).target3 == 1 
%         pre_th(animal_idx, :) = nanmedian(pre(33:48, :));
%         during_th(animal_idx, :) = nanmedian(during(33:48, :));
%         post_th(animal_idx, :) = nanmedian(post(33:48, :));
%     else 
%         pre_th(animal_idx, :) = NaN;
%         during_th(animal_idx, :) = NaN; 
%         post_th(animal_idx, :) = NaN; 
%     end 
    freqs = USVpower.freq; 
end 

figure; hold on; 
% plot(freqs, nanmedian(pre_acc)); 
% plot(freqs, nanmedian(during_acc), 'r');
boundedline(freqs, nanmedian(during_acc), nanstd(during_acc) ./ sqrt(size(during_acc, 1)));
boundedline(freqs, nanmedian(baseline_acc), nanstd(baseline_acc) ./ sqrt(size(baseline_acc, 1)), 'cmap', [0.4660 0.6740 0.1880]);
boundedline(freqs, nanmedian(prep_acc), nanstd(prep_acc) ./ sqrt(size(prep_acc, 1)),'r'); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xlabel('Frequency (Hz)'); 
ylabel('Power (\muV^2)');
set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
set(gca, 'YScale', 'log'); 
xlim([1 49]); 
legend('', 'during', '', 'baseline', '', 'prep')
title('ACC')

% figure; hold on; 
% % plot(freqs, nanmedian(pre_acc)); 
% % plot(freqs, nanmedian(during_acc), 'r');
% boundedline(freqs, nanmedian(pre_str), nanstd(pre_str) ./ sqrt(size(pre_str, 1))); 
% boundedline(freqs, nanmedian(post_str), nanstd(post_str) ./ sqrt(size(post_str, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% boundedline(freqs, nanmedian(during_str), nanstd(during_str) ./ sqrt(size(pre_str, 1)), 'r');
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'pre-USV', '', 'during USV', '', 'post-USV')
% title('DMS')
% 
% figure; hold on; 
% % plot(freqs, nanmedian(pre_acc)); 
% % plot(freqs, nanmedian(during_acc), 'r');
% boundedline(freqs, nanmedian(pre_th), nanstd(pre_th) ./ sqrt(size(pre_th, 1))); 
% boundedline(freqs, nanmedian(post_th), nanstd(post_th) ./ sqrt(size(post_th, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% boundedline(freqs, nanmedian(during_th), nanstd(during_th) ./ sqrt(size(pre_th, 1)), 'r');
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'pre-USV', '', 'during USV', '', 'post-USV')
% title('MD')



%% deprecated old section. Still works but not compatible with the dataframe currently used anymore.
% sentence detection and exclusion is now done in python. 
% Some differences in rounding or dropping (although not by the code itself) might explain 1-2 discrepancy between matlab and python.  

% clear
% experiments = get_experiment_redux;
% experiments = experiments([256:301 303 306 309 312 315 318 321 324:420]);  % 256:380 [300 301 324:399]
% % experiments = experiments([experiments.IUEconstruct] == 13);
% 
% minInterSyInt = 5000; % threshold to merge USV calls together, in ms
% 
% % signal loading params 
% sigparams.ch2load = 1:48; 
% sigparams.cores = 6; 
% sigparams.fs = 32000; % sampling rate from data
% sigparams.downsampling_factor = 160; % downsample for LFP analysis
% sigparams.low_cut = 1; 
% sigparams.ExtractMode = 1; % extract from neuralynx into matlab
% sigparams.length = 1; % signal length to for pre and post computation, in second
% 
% % pWelch params
% psparams. windowSize = 1;
% psparams. overlap = 0.4;
% psparams. nfft = 256;
% psparams. maxFreq = 100;
% 
% repeat_calc = 0; 
% folder2save = 'Q:\Personal\Tony\Analysis\Results_USVpower\'; 
% 
% % get unique animal numbers 
% animals = extractfield(experiments, 'animal_ID');
% animals = animals(~cellfun('isempty', animals));
% animals = unique(cellfun(@num2str, animals, 'un', 0));
% 
% % calculate one animal at a time 
% for animal_idx = 1 : size(animals, 2) 
%     tic
%     % get animal number and all experiments for this animal 
%     animal = animals{animal_idx}; 
%     experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
% 
%     USVpower = getUSVpower(experiments4mouse, minInterSyInt, sigparams, psparams, repeat_calc, folder2save); 
%     toc
% end 

% %% Plotting section 
% 
% pre_acc = []; 
% pre_str = []; 
% pre_th = []; 
% 
% during_acc = []; 
% during_str = []; 
% during_th = []; 
% 
% post_acc = []; 
% post_str = []; 
% post_th = []; 
% 
% for animal_idx = 1 : size(animals, 2) 
%     % get animal number and all experiments for this animal 
%     animal = animals{animal_idx}; 
%     experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
%     badch = rmmissing([experiments4mouse(1).NoisyCh experiments4mouse(1).OffCh]); 
% 
%     load([folder2save animal '.mat']);
%     pre = nanmean(USVpower.pre, 3); 
%     pre(badch, :) = NaN; 
%     during = nanmean(USVpower.during, 3); 
%     during(badch, :) = NaN; 
%     post = nanmean(USVpower.post, 3); 
%     post(badch, :) = NaN; 
% 
%     pre_acc(animal_idx, :) = nanmedian(pre(17:32, :)); 
%     during_acc(animal_idx, :) = nanmedian(during(17:32, :)); 
%     post_acc(animal_idx, :) = nanmedian(post(17:32, :)); 
% 
%     if experiments4mouse(1).target2 == 1
%         pre_str(animal_idx, :) = nanmedian(pre(1:16, :)); 
%         during_str(animal_idx, :) = nanmedian(during(1:16, :)); 
%         post_str(animal_idx, :) = nanmedian(post(1:16, :)); 
%     else 
%         pre_str(animal_idx, :) = NaN;
%         during_str(animal_idx, :) = NaN;  
%         post_str(animal_idx, :) = NaN; 
%     end 
%     if experiments4mouse(1).target3 == 1 
%         pre_th(animal_idx, :) = nanmedian(pre(33:48, :));
%         during_th(animal_idx, :) = nanmedian(during(33:48, :));
%         post_th(animal_idx, :) = nanmedian(post(33:48, :));
%     else 
%         pre_th(animal_idx, :) = NaN;
%         during_th(animal_idx, :) = NaN; 
%         post_th(animal_idx, :) = NaN; 
%     end 
%     freqs = USVpower.freq; 
% end 
% 
% figure; hold on; 
% % plot(freqs, nanmedian(pre_acc)); 
% % plot(freqs, nanmedian(during_acc), 'r');
% boundedline(freqs, nanmedian(pre_acc), nanstd(pre_acc) ./ sqrt(size(pre_acc, 1))); 
% boundedline(freqs, nanmedian(post_acc), nanstd(post_acc) ./ sqrt(size(post_acc, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% boundedline(freqs, nanmedian(during_acc), nanstd(during_acc) ./ sqrt(size(pre_acc, 1)), 'r');
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'pre-USV', '', 'during USV', '', 'post-USV')
% title('ACC')
% 
% figure; hold on; 
% % plot(freqs, nanmedian(pre_acc)); 
% % plot(freqs, nanmedian(during_acc), 'r');
% boundedline(freqs, nanmedian(pre_str), nanstd(pre_str) ./ sqrt(size(pre_str, 1))); 
% boundedline(freqs, nanmedian(post_str), nanstd(post_str) ./ sqrt(size(post_str, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% boundedline(freqs, nanmedian(during_str), nanstd(during_str) ./ sqrt(size(pre_str, 1)), 'r');
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'pre-USV', '', 'during USV', '', 'post-USV')
% title('DMS')
% 
% figure; hold on; 
% % plot(freqs, nanmedian(pre_acc)); 
% % plot(freqs, nanmedian(during_acc), 'r');
% boundedline(freqs, nanmedian(pre_th), nanstd(pre_th) ./ sqrt(size(pre_th, 1))); 
% boundedline(freqs, nanmedian(post_th), nanstd(post_th) ./ sqrt(size(post_th, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% boundedline(freqs, nanmedian(during_th), nanstd(during_th) ./ sqrt(size(pre_th, 1)), 'r');
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'pre-USV', '', 'during USV', '', 'post-USV')
% title('MD')



