%% STTC superficial vs deep layers and downstream areas   
% Tony, Oct 2023 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(240:281);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
cores = 6; 

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
BrainArea1 = 'ACC';
layer = 'deep'; % sup or deep
BrainArea2 = 'Str'; % Str or TH
if strcmp(BrainArea2, 'TH') 
    experiments = experiments(strcmp(extractfield(experiments, 'Area3'), 'TH')); 
end 

folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\ACC\'; 

lags = [5, 10, 20, 50, 100, 500]; % single lags for which to compute tiling coeff, in miliseconds
repeat_calc = 1;
save_data = 1;
folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\'; 

parfor (exp_idx = 1 : size(experiments, 2), cores)
    experiment = experiments(exp_idx); 

    % check for area and targeting, then compute STTC
    if strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area2, BrainArea2) 
        if experiment.target1 == 1 && experiment.target2 == 1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getSTTC_layer(experiment, folder4SM, BrainArea1, BrainArea2, folder4SUAinfo, layer, lags, repeat_calc, save_data, folder4STTC);
        end 
    elseif strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area3, BrainArea2) 
        if experiment.target1 ==1 && experiment.target3 ==1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getSTTC_layer(experiment, folder4SM, BrainArea1, BrainArea2, folder4SUAinfo, layer, lags, repeat_calc, save_data, folder4STTC);
        end 
    end 
end 

datetime 