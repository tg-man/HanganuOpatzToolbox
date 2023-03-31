%% Script to generate SUAinfo file 
% Tony
% run this and use the output SUAinfo file for all spike analysis 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments([85:88]); % what experiments to keep
save_data = 1;

% change the following folders according to brain areas analyzed 
folder4PRM = 'C:\Klusta\PRM\3Probe\ACC\';
folder4DAT = 'Q:\Personal\Tony\Analysis\Results_3Probe_DAT\ACC\';
folder2save = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\ACC\';

% get the unique animal IDs
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

for idx_animal = 1 : length(animals)
    
    % select experiment
    animal = animals{idx_animal};
    exp_idx = find(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
    experiment = experiments(exp_idx); 
    
    % select animal specific DAT folder 
    DAT = strcat(folder4DAT, animal, filesep); 
    
    % functions to generate SUAinfo file 
    disp(['generating SUAinfo for animal ' num2str(idx_animal) ' out of ' num2str(size(animals,2))])
    loadKlusta(animal, folder4PRM, DAT, save_data, folder2save);
end 

