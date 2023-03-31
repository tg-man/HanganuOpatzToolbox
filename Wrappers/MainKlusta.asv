
% This is a master script that runs the spike sorting algorithm klusta 
% (https://klusta.readthedocs.io/en/latest/) in a format that is friendly 
% to the neuralynx format and the way we save our recordings

%% load experiments and make animals (instead of experiment) the unit on which to sort

clear all
klusta = 1;
common_average_reference = 1; 
experiments = get_experiment_redux(klusta);
experiments = experiments([80:93]);

PRMfolder = 'C:\Klusta\PRM\3Probe\'; % main folder in which you store your PRM files 
                                    % (which then are in an area-specific and animal-specific subfolder, full path constructed in the loop)

DATfolder_animal = 'Q:/Personal/Tony/Analysis/Results_3Probe_DAT/'; % folder in which your .DAT and .PRB files will be saved 
                                                                    % / slash direction is important in this line. Don't change!
                                                                    % (better be on Q, unless you have a lot of space 
                                                                    % on your disk)
                                    
probetypes = {'4shank', '16_50m'}; % select the probe that you used for your experiments 
                                   % probes currently available are '4shank' and '16_50m'

BrainAreas = {'ACC','PL','Str','TH3'}; % list of brain areas to be iterated


% this part here follows the rationale of having multiple recordings 
% ("experiment" in the jergon of get_experiment_redux) from the same
% animal (i.e. a long opto experiment that was subdivided in
% multiple shorter recordings). This piece of code groups such recordings
% all together so that they can be spike-sorted all at the same time.
% If this is not the case for you, you can rearrange it to run over single
% recordings ("experiments") instead. 
 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

%% create PRB, PRM and DAT files

% creates PRB and PRM files and puts them into appropriate folders. Since
% the python shell only runs on files that are on C:/, the PRMfolder has 
% to be on C:/. However, since the output files are quite big, the 
% folder2save (where they end up) should better be on Q:/, unless you are 
% just trying out stuff and have space on your local disk. In this case, 
% having the files on your disk will significantly speed up the whole 
% process.

% The PRB file is a file that describes the geometry of the probe

% The PRM file is a file that specifies your preferences for the spike
% sorting process and where to find all the relevant files

% The DAT file is the format in which the recording will be read by the 
% sorting algorithm

% select the channels that you want to spike sort (as they are named in the
% neuralynx format)
channels = 1 : 16;
TH_mode = 0; % use 1 when sorting TH data; use 0 for other brain areas 

for idx_animal = 1 : length(animals)
    disp(['writing animal number ', num2str(idx_animal)])
    animal = animals{idx_animal};
    exp_idx = find(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
    broken_channels = experiments(exp_idx).NoisyCh; 
    broken_channels = intersect(channels, broken_channels);
   
    PRB2folder(probetype, DATfolder_animal)
    
    % create DAT from neuralynx files
    nlx2DAT(animal, experiments, channels, broken_channels, DATfolder_animal, common_average_reference)
    
    PRMfolder_animal = strcat(PRMfolder, animal);
    PRM2folder(animal, DATfolder_animal, PRMfolder_animal, TH_mode);
end

%% create BAT file 
% A BAT file is a script in lynux. Running klusta with a BAT file permits
% you to run it in batch mode, without having to go through a python
% shell.


% also loop over brain areas here! 
BATfolder = 'C:\Klusta\BAT files\Str\'; %change path for each brain area
createBAT(animals, BATfolder, PRMfolder) % CHANGE ONE PATH INSIDE!!!



