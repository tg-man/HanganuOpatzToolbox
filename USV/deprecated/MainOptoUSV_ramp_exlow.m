%% Ramp USV without weak vocalizers 

clear

StimArea = 'ACCsup'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 
% layer = 'sup'; 

minusvnum = 10; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folder4USV = 'Q:\Personal\Tony\Analysis\Results_USV\'; 

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

experiments = experiments([experiments.IUEage] > 19); 
experiments = experiments([1 10:end]);
% experiments = experiments(isnan([experiments.IUEage])); 
% experiments = experiments([3:end]);

animals = {experiments.animal_ID}; 

% get baseline experiments corresponding to the opto ones 
baselines = get_experiment_redux;
baselines = baselines(strcmp(extractfield(baselines, 'Exp_type'), 'baseline only'));
n = 1;
for exp_idx = 1 : size(baselines, 2) 
    baseline = baselines(exp_idx); 
    if ismember(baseline.animal_ID, animals)
        temp(n) = baseline;
        n = n + 1; 
    end 
end 
baselines = temp; 
% check baseline vocalization 
for exp_idx = 1 : size(baselines, 2) 
    baseline = baselines(exp_idx); 
    load([folder4USV baseline.USV]); 
    Calls = Calls(Calls.Accept == 1, :);
    if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8 
        filter(exp_idx) = (size(Calls, 1) - 2 > minusvnum);
    else 
        disp([experiment.USV ' start or end incorrectly labeled!'])
    end 
end 
% filter out low baseline vocalizers 
experiments = experiments(filter); 

[p1, p2] = plotRampUSV(experiments, folder4stim, StimArea); 
disp([p1 p2])



