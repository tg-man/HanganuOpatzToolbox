%% Ramp USV for control with both opto session pooled together 

clear
experiments = get_experiment_redux;
experiments = experiments([256:end]);
experiments = experiments([experiments.DiI] == 0); 
experiments = experiments(isnan([experiments.IUEage])); 

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
minusvnum = 10; 

baselines = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
optos = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto')); 
clear experiments

% check baseline vocalization & filter out low baseline vocalizers 
for exp_idx = 1 : size(baselines, 2) 
    baseline = baselines(exp_idx); 
    load([baseline.USV_path baseline.USV]); 
    Calls = Calls(Calls.Accept == 1, :);
    if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8 
        filter(exp_idx) = (size(Calls, 1) - 2 > minusvnum);
    else 
        disp([experiment.USV ' start or end incorrectly labeled!'])
    end 
end 
baselines = baselines(filter); 
% filter opto experiments to get rid of weak vocalizers 
animals = extractfield(baselines, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));
for exp_idx = 1 : size(optos, 2)
    opto = optos(exp_idx); 
    if ismember(opto.animal_ID, animals)
        filter(exp_idx) = ismember(opto.animal_ID, animals); 
    else 
        filter(exp_idx) = false; 
    end 
end 
optos = optos(filter); 
experiments = optos; 

[p1, p2] = plotRampUSVpoolctrl(experiments, folder4stim); 
disp([p1 p2])




