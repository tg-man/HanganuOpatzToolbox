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
repeat_calc = 1;
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

