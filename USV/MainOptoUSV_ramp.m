%% Ramp USV 

clear

StimArea = 'ACCsup'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 
% layer = 'sup'; 

experiments = get_experiment_redux;
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));

% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 87);

experiments = experiments([experiments.DiI] == 0); 
% experiments = experiments([experiments.DiI] == 1); 

experiments = experiments(strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(strcmp(extractfield(experiments, 'Area1'), 'PL'));

% experiments = experiments([experiments.IUEage] > 19); 
% experiments = experiments([8:end]);

experiments = experiments(isnan([experiments.IUEage])); 
experiments = experiments([3:end]);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';

[p1, p2] = plotRampUSV(experiments, folder4stim, StimArea); 
disp([p1 p2])


