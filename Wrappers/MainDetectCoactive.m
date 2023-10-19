%% coactive periods detection 
%  using the oscillation struct from BasicLFPAnalysis to generate timestamps
%  of coactive periods between signals of different area from the same
%  multi-site recording 
clear

% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments([205:233]); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

% folders to grab various results
folder4osc2 = 'Q:\Personal\Tony\Analysis\Results_2Probe_osc\';
folder4osc3 = 'Q:\Personal\Tony\Analysis\Results_3Probe_osc\';

folder4coactive12 = 'Q:\Personal\Tony\Analysis\Results_Coactive\ACCStr\';
folder4coactive13 = 'Q:\Personal\Tony\Analysis\Results_Coactive\ACCTH\';
save_data = 1;

%% actually doing the coactive period detection 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    
    % load ACC timestamps 
    if strcmp(experiment.sites, '2site') && experiment.target1 == 1 
        load([folder4osc2, experiment.Area1, '\', experiment.animal_ID]);
    elseif strcmp(experiment.sites, '3site') && experiment.target1 == 1 
        load([folder4osc3, experiment.Area1, '\', experiment.animal_ID]);
    end 
    % extract timestamps and some other parameters
    if experiment.target1 == 1 
        timestamps1 = oscillations.timestamps;
        fs = oscillations.fs;
        len_rec = oscillations.len_rec;
    end 
    clear oscillations

    % load Str timestamps
    if strcmp(experiment.sites, '2site') && experiment.target2 == 1 
        load([folder4osc2, experiment.Area2, '\', experiment.animal_ID]);
        timestamps2 = oscillations.timestamps;
    elseif strcmp(experiment.sites, '3site') && experiment.target2 == 1 
        load([folder4osc3, experiment.Area2, '\', experiment.animal_ID]);
        timestamps2 = oscillations.timestamps;
    end 
    clear oscillations 

     % load TH timestamps if 3site 
    if strcmp(experiment.sites, '3site') && experiment.target3 == 1 
        load([folder4osc3, experiment.Area3, '\', experiment.animal_ID]);
        timestamps3 = oscillations.timestamps; 
    end 
    clear oscillations 

    % detect coactive periods ACC Str 
    if experiment.target1 == 1 && experiment.target2 == 1 
        getCoactivePeriods(experiment, timestamps1, timestamps2, fs, len_rec, save_data, folder4coactive12);
    end

    % detect coactive periods ACC TH (if applicable) 
    if strcmp(experiment.sites, '3site') && experiment.target3 == 1 && experiment.target1 == 1 
        getCoactivePeriods(experiment, timestamps1, timestamps3, fs, len_rec, save_data, folder4coactive13);
    end
end 

