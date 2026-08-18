%% main USV sentence STTC 
% compute STTC values on a single sentence basis 
% input: 
%     experiments 
%     sentence csv 
%     spike matrix 
% 
% output: 
%     struct with STTC values in 1) baseline 2) peri 
%     2 separate structure with 2 separate saving paths 

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

cores = 4;

% areas 
area1 = 'ACC'; 
area2 = 'Str'; 
% intervals between sentences, in ms
ISI = 5000; 
% STTC function wrapper stuff
repeat_calc = 0;
lags = [5, 10, 20, 50, 100, 500];
% for df to R 
lag_idx = 6; 


% links
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVSTTC_sentence_2phases_longdur\'; 

% all animals 
animals = unique(T.mouse); 

% loop through each animal 
% parfor (mouse_idx = 1 : numel(animals), cores)
for mouse_idx = 1 : numel(animals)
    mouse = animals{mouse_idx}; 
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
    getSentenceSTTCx_2phases(T_mouse, folder4SM, area1, area2, lags, repeat_calc, folder2save); 
    toc
end 



%% generate csv for R 


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

    % peri section extract data and put into 
    peri = squeeze(sentenceSTTC.peri(:, lag_idx, :));
    % reshape to linear vector 
    peri = reshape(peri, [], 1);
    trial_peri = reshape(trial, [], 1);
    % filter out NaNs (order is important!) 
    trial_peri = trial_peri(~isnan(peri));
    pair_peri = pair(~isnan(peri));
    peri = peri(~isnan(peri)); 

    % put into a table 
    temp = table(repmat({mouse}, [numel([baseline; peri]), 1]), ...
        [baseline; peri], ...
        [trial_baseline; trial_peri], ...
        [pair_baseline; pair_peri], ...
        [repmat({'baseline'}, [numel(baseline), 1]); repmat({'peri'}, [numel(peri), 1])], ...
        'VariableNames', {'mouse', 'sttc', 'trial', 'pair', 'phase'}); 
    % add to total table 
    USVSTTC = [USVSTTC; temp]; 
    clearvars temp 
    
end 

writetable(USVSTTC, [folder2save 'sentenceSTTC_ACCStr_' num2str(lag_idx) '.csv' ], 'Delimiter', ',');

% %% tester section 
% 
% 
% clear
% % load table with all USV sentences 
% filename = 'Q:/Personal/Tony/Analysis/USV_csvs/ephysUSV_sentence_features_1s.csv';
% opts = detectImportOptions(filename, 'Delimiter', ',');
% opts = setvartype(opts, "sentence", "string");
% T = readtable(filename, opts);
% 
% % get rid of opto sessions 
% T = T(strcmp(T.condition, 'baseline'), :); 
% % get rid of single calls 
% T = T(T.length > 1, :); 
% 
% lag_idx = [5 6];
% 
% % areas 
% area1 = 'ACC'; 
% area2 = 'Str'; 
% folder2save = 'Q:\Personal\Tony\Analysis\Results_USVSTTC_sentence_2phases\'; 
% 
% % all animals 
% animals = unique(T.mouse); 
% 
% Tcomp = []; 
% 
% % version 1: all sentences all pairs 
% for mouse_idx = 1 : numel(animals) 
%     mouse = animals{mouse_idx}; 
%     load([folder2save area1 area2 '/' ,mouse]); 
% 
%     % baseline section extract data and put into 
%     baseline5 = squeeze(sentenceSTTC.baseline(:, lag_idx(1), :));
%     % reshape to linear vector 
%     baseline5 = reshape(baseline5, [], 1);
%     % count real values 
%     baseline5 = sum(~isnan(baseline5));
% 
%     % baseline section extract data and put into 
%     baseline6 = squeeze(sentenceSTTC.baseline(:, lag_idx(2), :));
%     % reshape to linear vector 
%     baseline6 = reshape(baseline6, [], 1);
%     % count real values 
%     baseline6 = sum(~isnan(baseline6));
% 
%     % put into a table 
%     temp = table(repmat({mouse}, [numel([baseline; peri]), 1]), ...
%         [baseline; peri], ...
%         [trial_baseline; trial_peri], ...
%         [pair_baseline; pair_peri], ...
%         [repmat({'baseline'}, [numel(baseline), 1]); repmat({'peri'}, [numel(peri), 1])], ...
%         'VariableNames', {'mouse', 'sttc', 'trial', 'pair', 'phase'}); 
%     % add to total table 
%     USVSTTC = [USVSTTC; temp]; 
%     clearvars temp 
%     
% end 
% 
