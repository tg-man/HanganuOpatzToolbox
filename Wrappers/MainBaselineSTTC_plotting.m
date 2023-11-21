%% STTC plotting script 
% Tony Oct 2023

% section to plot within area STTC 
clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 

BrainArea = 'ACC'; % ACC, Str, TH 
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\';

if strcmp(BrainArea, 'Str') 
    experiments = experiments(extractfield(experiments, 'target2') == 1); 
elseif strcmp(BrainArea, 'TH')
    experiments = experiments(extractfield(experiments, 'target3') == 1); 
end 

STTCs = []; 
Dists = []; 
ages = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load STTC values 
    load([folder4STTC BrainArea '\' experiment.animal_ID])
    STTCs = [STTCs; Tcoeff.TilingCoeff]; 

    % load distance values 
    load([folder4STTC 'Distance\' BrainArea '\' experiment.name])
    Dists = [Dists; Dist]; 

    if Tcoeff.num_pairs ~= size(Dist, 1) 
        disp([experiment.animal_ID])
    end 

    % assign age vector
    ages = [ages; repmat(experiment.age, [numel(Dist) 1])];
end 
lags = Tcoeff.lags * 1000; % convert to seconds for better readibility  
STTCs = STTCs - min(STTCs) + 0.0001; % shift all STTC values to above zero 
STTCs = log(STTCs); 


for lag_idx = 1 : numel(lags)
    STTC = STTCs(:, lag_idx);
    lag = lags(lag_idx); 
    tbl2fit = table(Dists, ages, STTC);
    mdl = fitlm(tbl2fit, 'STTC ~ Dists + ages + Dists*ages'); 
    figure; f = plotInteraction(mdl, 'ages', 'Dists', 'predictions'); 
    title([BrainArea num2str(lag) ' ms'])
end 


%% section to plot between area STTC 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

BrainArea1 = 'ACCdeep'; 
BrainArea2 = 'TH'; % ACC, Str, TH 
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\';

if strcmp(BrainArea2, 'Str') 
    experiments = experiments(extractfield(experiments, 'target2') == 1); 
elseif strcmp(BrainArea2, 'TH')
    experiments = experiments(extractfield(experiments, 'target3') == 1); 
end 

STTCs = []; 
Dists = []; 
ages = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load STTC values 
    load([folder4STTC BrainArea1 BrainArea2 '\' experiment.name])
    STTCs = [STTCs; Tcoeff.STTC]; 

    % assign age vector
    ages = [ages; repmat(experiment.age, [size(Tcoeff.STTC, 1) 1])];
end 
lags = Tcoeff.lags * 1000; % convert to seconds for better readibility  
STTCs = STTCs - min(STTCs) + 0.0001; % shift all STTC values to above zero 
STTCs = log10(STTCs); 

for lag_idx = 1 : numel(lags)
    STTC = STTCs(:, lag_idx);
    lag = lags(lag_idx); 
    figure; 
    violins = violinplot(STTC, ages, 'ShowData', false, 'ViolinAlpha', 1, 'EdgeColor', [0 0 0]); 
    for idx = 1:size(violins, 2)
        violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    end
    ylabel('log of STTC'); xlabel('Age (P)'); xlim([0.5 8.5]); ylim([-2 -0.5]); 
    set(gca, 'FontName', 'Arial', 'FontSize', 14); 
    title([BrainArea1 ' ' BrainArea2 ' ' num2str(lag) ' ms'], 'FontSize', 14, 'FontName', 'Arial'); 
end 

% 
% for lag_idx = 1 : numel(lags)
%     STTC = STTCs(:, lag_idx);
%     lag = lags(lag_idx); 
%     tbl2fit = table(ages, STTC);
%     mdl = fitlm(tbl2fit)
%     figure; f = plotAdjustedResponse(mdl, 'ages'); 
%     xlim([4.5 12.5]);
%     title([BrainArea1 ' ' BrainArea2 ' ' num2str(lag) ' ms'])
% end 


