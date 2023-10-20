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
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\';

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

    % assign age vector
    ages = [ages; repmat(experiment.age, [numel(Dist) 1])];
end 
lags = Tcoeff.lags * 1000; % convert to seconds for better readibility  

for lag_idx = 1 : numel(lags) 
    lag = lags(lag_idx); 
    f = figure; hold on; 
    for age_idx = 5 : 12
        color = YlGnBu(round(100/8 * (age_idx - 4)),:); 
        scatter(Dists(ages == age_idx), STTCs(ages == age_idx), 'MarkerEdgeColor','none', 'MarkerFaceColor', color, 'MarkerFaceAlpha', 0.7); 
    end 
    xlabel('Distance(\mum)'); ylabel('STTC (au)'); 
    title([BrainArea ' ' num2str(lag) 'ms']); 
end 







%% section to plot between area STTC 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 


BrainArea = 'TH'; % ACC, Str, TH 
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 

lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff
repeat_calc = 1;
save_data = 1;
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\';