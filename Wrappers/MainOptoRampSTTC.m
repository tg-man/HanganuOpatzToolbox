%% Ramp STTC 


clear; 
experiments = get_experiment_redux;
experiments = experiments([73:233]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );

lags = [5, 10, 20, 50, 100, 500]