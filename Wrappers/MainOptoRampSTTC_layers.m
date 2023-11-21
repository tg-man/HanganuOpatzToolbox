%% Ramp STTC 

clear; 
experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );

lags = [5, 10, 20, 50, 100, 500]; 

folder4OM = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\'; 
BrainArea1 = 'ACC'; 
layer = 'deep'; % sup or deep
BrainArea2 = 'TH'; % Or TH here 
if strcmp(BrainArea2, 'TH') 
    experiments = experiments(strcmp(extractfield(experiments, 'Area3'), 'TH')); 
end 

folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\ACC\'; 

repeat_calc = 1;
save_data = 1;
folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';

for exp_idx = 1 : size(experiments, 2)
    experiment  = experiments(exp_idx); 

    % check for area and targeting, then compute STTC
    if strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area2, BrainArea2) 
        if experiment.target1 == 1 && experiment.target2 == 1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getRampSTTC_layer(experiment, folder4OM, BrainArea1, BrainArea2, folder4SUAinfo, layer, lags, repeat_calc, save_data, folder4OSTTC);
        end     
    elseif strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area3, BrainArea2) 
        if experiment.target1 ==1 && experiment.target3 ==1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getRampSTTC_layer(experiment, folder4OM, BrainArea1, BrainArea2, folder4SUAinfo, layer, lags, repeat_calc, save_data, folder4OSTTC); 
        end 
    end 
end 