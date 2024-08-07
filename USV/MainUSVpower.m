%% USV power
% wavelet workflow from Sebastian 

clear
experiments = get_experiment_redux;
experiments = experiments(256:380);  % 256:380 [300 301 324:380]

minInterSyInt = 5000; % threshold to merge USV calls together, in ms

% signal loading params 
sigparams.ch2load = 1:48; 
sigparams.cores = 6; 
sigparams.fs = 32000; % sampling rate from data
sigparams.downsampling_factor = 160; % downsample for LFP analysis
sigparams.low_cut = 1; 
sigparams.ExtractMode = 1; % extract from neuralynx into matlab
sigparams.length = 1; % signal length to cut, in second

% pWelch params 
psparams. windowSize = 1;
psparams. overlap = 0.4;
psparams. nfft = 256;
psparams. maxFreq = 100;

repeat_calc = 0; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVpower\'; 

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

%% calculate one animal at a time 

for animal_idx = 1 : size(animals, 2) 
    tic
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 

    USVpower = getUSVpower(experiments4mouse, minInterSyInt, sigparams, psparams, repeat_calc, folder2save); 
    toc
end 