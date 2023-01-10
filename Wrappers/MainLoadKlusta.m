%% Script to generate SUAinfo file 
% Tony
% run this and use the output SUAinfo file for all spike analysis 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([49]); % what experiments to keep
save_data = 1;

% change the following folders according to brain areas analyzed 
folder4PRM = 'C:\Klusta\PRM\3Probe\TH3\';
folder4DAT = 'Q:\Personal\Tony\Analysis\Results_3Probe_DAT\TH3\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\TH3\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx); 
    
    % select animal specific DAT folder 
    DAT = strcat(folder4DAT, experiment.animal_ID, filesep); 
    
    % functions to generate SUAinfo file 
    disp(['generating SUAinfo for animal ' num2str(exp_idx) ' out of ' num2str(size(experiments,2))])
    loadKlusta(experiment.animal_ID, folder4PRM, DAT, save_data, folder2save);
end 