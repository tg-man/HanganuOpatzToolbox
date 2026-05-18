%% USV power

clear
% get experiments 
experiments = get_experiment_redux;
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only')); 

% load table with all USV sentences 
filename = 'Q:/Personal/Tony/Analysis/USV_csvs/ephysUSV_sentence_features_1s.csv';
opts = detectImportOptions(filename, 'Delimiter', ',');
opts = setvartype(opts, "sentence", "string");
T = readtable(filename, opts);

% sentence interval 
ISI = 5000; 

% get rid of opto sessions 
T = T(strcmp(T.condition, 'baseline'), :); 
% get rid of single calls 
T = T(T.length > 1, :); 

% signal loading params 
sigparams.ch2load = 1:48; 
sigparams.cores = 4; 
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
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVpower_2phases\'; 

% get unique animal numbers 
animals = unique(T.mouse); 

% calculate one animal at a time 
for animal_idx = 1 : size(animals, 1) 
    tic
    disp(['computing animal ' num2str(animal_idx) ' / ' num2str(numel(animals))])
    % get animal number and all experiments for this animal 
    mouse = animals{animal_idx}; 
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

    % get experiment of the mouse 
    experiments_mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), mouse)); 

    % compute 
    USVpower = getUSVpower_2phases(experiments_mouse, T_mouse, sigparams, psparams, repeat_calc, folder2save); 
    toc
end 

datetime

%% plotting 

baseline_acc = []; 
baseline_str = []; 

peri_acc = []; 
peri_str = []; 

for animal_idx = 1 : size(animals, 1) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
    badch = rmmissing([experiments4mouse(1).NoisyCh experiments4mouse(1).OffCh]); 

    % grab number from file and get rid of bad channels  
    load([folder2save animal '.mat']);
    baseline = nanmean(USVpower.baseline, 3); 
    baseline(badch, :) = NaN; 
    peri = nanmean(USVpower.peri, 3); 
    peri(badch, :) = NaN; 

    % get acc power average across trials 
    baseline_acc(animal_idx, :) = nanmedian(baseline(17:32, :)); 
    peri_acc(animal_idx, :) = nanmedian(peri(17:32, :)); 

    % get str power average across trials 
    if experiments4mouse(1).target2 == 1
        baseline_str(animal_idx, :) = nanmedian(baseline(1:16, :)); 
        peri_str(animal_idx, :) = nanmedian(peri(1:16, :)); 
    else 
        baseline_str(animal_idx, :) = NaN; 
        peri_str(animal_idx, :) = NaN; 
    end 
%     if experiments4mouse(1).target3 == 1 
%         pre_th(animal_idx, :) = nanmedian(pre(33:48, :));
%         post_th(animal_idx, :) = nanmedian(post(33:48, :));
%     else 
%         pre_th(animal_idx, :) = NaN;
%         post_th(animal_idx, :) = NaN; 
%     end 
    freqs = USVpower.freq; 
end 

figure; hold on; 
boundedline(freqs, nanmedian(baseline_acc), nanstd(baseline_acc) ./ sqrt(size(baseline_acc, 1)));
boundedline(freqs, nanmedian(peri_acc), nanstd(peri_acc) ./ sqrt(size(peri_acc, 1)),'cmap', [0.4660 0.6740 0.1880]); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xlabel('Frequency (Hz)'); 
ylabel('Power (\muV^2)');
set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
set(gca, 'YScale', 'log'); 
xlim([1 49]); 
legend('', 'baseline', '', 'peri')
title('Cingulate')

figure; hold on; 
boundedline(freqs, nanmedian(baseline_str), nanstd(baseline_str) ./ sqrt(size(baseline_str, 1)));
boundedline(freqs, nanmedian(peri_str), nanstd(peri_str) ./ sqrt(size(peri_str, 1)), 'cmap', [0.4660 0.6740 0.1880]); 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xlabel('Frequency (Hz)'); 
ylabel('Power (\muV^2)');
set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
set(gca, 'YScale', 'log'); 
xlim([1 49]); 
legend('', 'baseline', '', 'peri')
title('Striatum')

% figure; hold on; 
% boundedline(freqs, nanmedian(post_th), nanstd(post_th) ./ sqrt(size(post_th, 1)));
% boundedline(freqs, nanmedian(during_th), nanstd(during_th) ./ sqrt(size(pre_th, 1)), 'cmap', [0.4660 0.6740 0.1880]);
% lines = findobj(gcf,'Type','Line');
% for i = 1:numel(lines)
%   lines(i).LineWidth = 2;
% end
% xlabel('Frequency (Hz)'); 
% ylabel('Power (\muV^2)');
% set(gca, 'TickDir', 'out', 'FontName', 'Arial', 'FontSize', 14, 'LineWidth', 2); 
% set(gca, 'YScale', 'log'); 
% xlim([1 49]); 
% legend('', 'baseline', '', 'peri')
% title('MD')





