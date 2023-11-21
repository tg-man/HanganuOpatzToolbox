%% 

clear; 
experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')) );

lags = [5, 10, 20, 50, 100, 500]; 

BrainArea1 = 'ACCsup'; 
BrainArea2 = 'Str'; % Or TH here 
if strcmp(BrainArea2, 'Str') 
    experiments = experiments(extractfield(experiments, 'target2') == 1); 
elseif strcmp(BrainArea2, 'TH')
    experiments = experiments(extractfield(experiments, 'target3') == 1); 
end 

repeat_calc = 1;
save_data = 1;
folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';

pre = []; 
during = []; 
age = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment  = experiments(exp_idx); 
    load([folder4OSTTC BrainArea1 BrainArea2 '\' experiment.name])
    pre = [pre; RampSTTC.STTC_pre]; 
    during = [during; RampSTTC.STTC_during]; 
    age = [age; repmat(experiment.age, [size(RampSTTC.STTC_pre, 1) 1])];

end 
lags = RampSTTC.lags * 1000; % convert to seconds for better readibility  
pre = pre - min(pre) + 0.0001; % shift all STTC values to above zero 
during = during - min(during) + 0.0001; 
pre = log10(pre); 
during = log10(during); 

for lag_idx = 1 : numel(lags) 
    lag = lags(lag_idx); 
    pre2plot = pre(:, lag_idx); 
    during2plot = during(:, lag_idx); 
    figure; 
    scatter(pre2plot, during2plot, 'MarkerFaceColor', [1 0 0], 'MarkerFaceAlpha', 0.3, 'MarkerEdgeColor', [1 0 0], 'MarkerEdgeAlpha', 0.3); hold on; 
    xlabel('log STTC pre'); ylabel('log STTC during'); set(gca, 'FontSize', 14, 'FontName', 'Arial'); 
    title(['STTC ' BrainArea1 ' ' BrainArea2 ' ' num2str(lag) 'ms']); 
    plot([-4 1], [-4 1], 'k');
end 


