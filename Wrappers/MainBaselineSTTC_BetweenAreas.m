%% STTC between two different Brain areas  
% Tony, Oct 2023 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
cores = 6; 

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
BrainArea1 = 'ACC'; 
BrainArea2 = 'Str'; % Or TH here 
if strcmp(BrainArea2, 'TH') 
    experiments = experiments(strcmp(extractfield(experiments, 'Area3'), 'TH')); 
end 

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
            getSTTC_ba(experiment, folder4SM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4STTC); 
        end 
    elseif strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area3, BrainArea2) 
        if experiment.target1 ==1 && experiment.target3 ==1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getSTTC_ba(experiment, folder4SM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4STTC); 
        end 
    end 
end 
