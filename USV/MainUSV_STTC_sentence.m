%% main USV sentence STTC 
% compute STTC values on a single sentence basis 
% input: 
%     experiments 
%     sentence csv 
%     spike matrix 
% 
% output: 
%     struct with STTC values in 1) baseline 2) prep and 3) during 
%     3 separate structure with 3 separate saving paths 

clear
% load table with all USV sentences 
T = readtable('Q:/Personal/Tony/Analysis/USV_csvs/ephysUSV_sentence_features.csv', 'Delimiter',','); 

cores = 4;

% areas 
area1 = 'ACC'; 
area2 = 'Str'; 
% STTC function wrapper stuff
repeat_calc = 0;
lags = [5, 10, 20, 50, 100, 500];

% links
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVSTTC_sentence\'; 

% all animals 
animals = unique(T.mouse); 

% loop through each animal 
parfor (mouse_idx = 1 : numel(animals), cores)
% for mouse_idx = 1 : numel(animals)
    mouse = animals{mouse_idx}; 
    T_mouse = T(strcmp(T.mouse, mouse), :); 

%     % get within-area1 STTC 
%     tic
%     disp(['computing STTC within ' area1 '... ' num2str(mouse_idx) ' / ' num2str(numel(animals))])
%     getSentenceSTTCwithin(T_mouse, folder4SM, area1, lags, repeat_calc, folder2save); 
%     toc
% 
%     % get within-area2 STTC 
%     tic
%     disp(['computing STTC within ' area2 '... ' num2str(mouse_idx) ' / ' num2str(numel(animals))])
%     getSentenceSTTCwithin(T_mouse, folder4SM, area2, lags, repeat_calc, folder2save); 
%     toc
%     
    % get within-area2 STTC 
    tic
    disp(['computing STTC ' area1 ' x ' area2 '... ' num2str(mouse_idx) ' / ' num2str(numel(animals))])
    getSentenceSTTCx(T_mouse, folder4SM, area1, area2, lags, repeat_calc, folder2save); 
    toc
end 


%% generate csv for R 

lag_idx = 5; 

USVSTTC = []; 

% version 1: all sentences all pairs 
for mouse_idx = 1 : numel(animals) 
    mouse = animals{mouse_idx}; 
    load([folder2save area1 area2 '/' ,mouse]); 

    % baseline section extract data and put into 
    baseline = squeeze(sentenceSTTC.baseline(:, lag_idx, :));
    % get trial and pair IDs 
    trial= repmat(1:size(baseline, 2), [size(baseline, 1), 1]);
    pair = repmat(1:size(baseline, 1), [1, size(baseline, 2)])';
    % reshape to linear vector 
    baseline = reshape(baseline, [], 1);
    trial_baseline = reshape(trial, [], 1);
    % filter out NaNs (order is important!) 
    trial_baseline = trial_baseline(~isnan(baseline));
    pair_baseline = pair(~isnan(baseline));
    baseline = baseline(~isnan(baseline)); 

    % prep section extract data and put into 
    prep = squeeze(sentenceSTTC.prep(:, lag_idx, :));
    % reshape to linear vector 
    prep = reshape(prep, [], 1);
    trial_prep = reshape(trial, [], 1);
    % filter out NaNs (order is important!) 
    trial_prep = trial_prep(~isnan(prep));
    pair_prep = pair(~isnan(prep));
    prep = prep(~isnan(prep)); 

    % during section extract data and put into 
    during = squeeze(sentenceSTTC.during(:, lag_idx, :));
    % reshape to linear vector 
    during = reshape(during, [], 1);
    trial_during = reshape(trial, [], 1);
    % filter out NaNs (order is important!) 
    trial_during = trial_during(~isnan(during));
    pair_during = pair(~isnan(during)); 
    during = during(~isnan(during)); 

    % put into a table 
    temp = table(repmat({mouse}, [numel([baseline; prep; during]), 1]), ...
        [baseline; prep; during], ...
        [trial_baseline; trial_prep; trial_during], ...
        [pair_baseline; pair_prep; pair_during], ...
        [repmat({'baseline'}, [numel(baseline), 1]); repmat({'prep'}, [numel(prep), 1]); repmat({'during'}, [numel(during), 1])], ...
        'VariableNames', {'mouse', 'sttc', 'trial', 'pair', 'phase'}); 
    % add to total table 
    USVSTTC = [USVSTTC; temp]; 
    clearvars temp 
    
end 

% % version 2: all pairs sentence mean
% for mouse_idx = 1 : numel(animals) 
%     mouse = animals{mouse_idx}; 
%     load([folder2save area1 area2 '/' ,mouse]); 
% 
%     baseline = nanmean(squeeze(sentenceSTTC.baseline(:, lag_idx, :)), 2); 
%     baseline = baseline(~isnan(baseline)); 
% 
%     prep = nanmean(squeeze(sentenceSTTC.prep(:, lag_idx, :)), 2);
%     prep = prep(~isnan(prep)); 
% 
%     during = nanmean(squeeze(sentenceSTTC.during(:, lag_idx, :)), 2);
%     during = during(~isnan(during)); 
% 
%     temp = table(repmat({mouse}, [numel([baseline; prep; during]), 1]), ...
%         [baseline; prep; during], ...
%         [repmat({'baseline'}, [numel(baseline), 1]); repmat({'prep'}, [numel(prep), 1]); repmat({'during'}, [numel(during), 1])], ...
%         'VariableNames', {'mouse', 'sttc', 'phase'}); 
% 
%     USVSTTC = [USVSTTC; temp]; 
%     clearvars temp sentenceSTTC baseline prep during
% end 

writetable(USVSTTC, [folder2save 'sentenceSTTC_ACCStr.csv' ], 'Delimiter', ',');
