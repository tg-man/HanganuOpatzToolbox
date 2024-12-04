%% Ramp STTC 

clear; 
experiments = get_experiment_redux;
experiments = experiments(327:420);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCdeep'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );

lags = [5, 10, 20, 50, 100, 500, 1000]; 

folder4OM = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\'; 
BrainArea1 = 'ACC'; 
BrainArea2 = 'TH'; % Str or TH

if strcmp(BrainArea2, 'TH') 
    experiments = experiments(strcmp(extractfield(experiments, 'Area3'), 'TH')); 
end 

repeat_calc = 0;
save_data = 1;
folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';

%% 

for exp_idx = 1 : size(experiments, 2)
    tic
    experiment  = experiments(exp_idx); 
    disp(['computing experiment ' num2str(exp_idx) '... '])

    % check for area and targeting, then compute STTC
    if strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area2, BrainArea2) 
        if experiment.target1 == 1 && experiment.target2 == 1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getRampSTTC_ba(experiment, folder4OM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4OSTTC);
        end     
    elseif strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area3, BrainArea2) 
        if experiment.target1 ==1 && experiment.target3 ==1 
            disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
            getRampSTTC_ba(experiment, folder4OM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4OSTTC); 
        end 
    end 
    toc
end 

%% plotting 

clear; 
experiments = get_experiment_redux;
experiments = experiments([300 301 324:420]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);

folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';

accstr_pre = []; 
accstr_during = []; 
accth_pre = []; 
accth_during = []; 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
    % load ACC Str data 
    if experiment.target2 == 1 
        load([folder4OSTTC 'ACCStr\' experiment.name]); 
        accstr_pre = [accstr_pre; RampSTTC.STTC_pre]; 
        accstr_during = [accstr_during; RampSTTC.STTC_during]; 
    end 
    clear RampSTTC 
    % load ACC TH data 
    if experiment.target3 == 1 
        load([folder4OSTTC 'ACCTH\' experiment.name]); 
        accth_pre = [accth_pre; RampSTTC.STTC_pre]; 
        accth_during = [accth_during; RampSTTC.STTC_during]; 
        lags = RampSTTC.lags; 
    end 
    clear RampSTTC 
end

for lag_idx = 3 : length(lags) 
    
    % ACC x Str 
    % shift values to positive 
    shift = abs(min([accstr_pre(:, lag_idx); accstr_during(:, lag_idx)])) + 0.0001; 
    vec2plot = log10([accstr_pre(:, lag_idx), accstr_during(:, lag_idx)] + shift); % log10 not log!!!!! 
    figure; hold on; 
    violins = violinplot(vec2plot); 
    ylabel('log10 of shifted STTC'); xticklabels({'pre', 'during'});
    set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
    title(['ACC-Str ' num2str(lags(lag_idx)*1000) 'ms lag']);

    % ACC x TH
    % shift values to positive 
    shift = abs(min([accth_pre(:, lag_idx); accth_during(:, lag_idx)])) + 0.0001; 
    vec2plot = log10([accth_pre(:, lag_idx), accth_during(:, lag_idx)] + shift); % log10 not log!!!!! 
    figure; hold on; 
    violins = violinplot(vec2plot); 
    ylabel('log10 of shifted STTC'); xticklabels({'pre', 'during'});
    set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
    title(['ACC-TH ' num2str(lags(lag_idx)*1000) 'ms lag']);
end 

