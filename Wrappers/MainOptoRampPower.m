%% compute Ramp Power 

clear; 
experiments = get_experiment_redux;
for i = 1 : size(experiments, 2)
    experiment = experiments(i); 
    if length(experiment.IUEconstruct) == 1
        keep(i) = 1; 
    else
        keep(i) = 0; 
    end 
end 
experiments = experiments(logical(keep)); %[300 301 324:426]
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments([experiments.DiI] == 0); 
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13 | isnan(extractfield(experiments, 'IUEconstruct')));

save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_RampPower\'; % getRampPower params needs to be adjusted accordingly! 

% params for signal loading 
params.ExtractMode = 2; % for extracting nlx data
params.fs = 32000; % sampling rate
% params for time window: signal is loaded 4s before & 5s after ramp 
params.pre = 2500 : 3999;
params.first_half = 4001 : 5500;
params.second_half = 5501 : 7000;
params.post = 7001 : 8500;
% parameters for pWelch
params.windowSize = 1;
params.overlap = 0.4;
params.nfft = 1024;
params.maxFreq = 100;
params.downsample_factor = 32; % from 32k Hz 

cores = 4; 

% compute/plot ramp power stuff
getStimProperties(experiments, save_data, 0, folder4stim)

for idx = 1 : numel(experiments)
    tic
    experiment = experiments(idx); 
    disp(['running experiment number ' num2str(idx) ' out of ' num2str(size(experiments, 2))])
    if strcmp(experiment.sites, '2site') 
        CSCs = 1:32; 
    elseif strcmp(experiment.sites, '3site')
        CSCs = 1:48; 
    end 
    parfor (CSC = CSCs, cores) 
        getRampPower(experiment, CSC, save_data, params, repeatCalc, folder4stim, folderPowRamps);
    end 
    toc
end

% bad channels were taking out during plotting 
plotRampPower(experiments, 'ACC', 17:32, folderPowRamps);
plotRampPower(experiments, 'ACC', 1:16, folderPowRamps);

%plotRampSignal(experiment, CSC, save_data, repeatCalc, folder4stim, folderPowRamps); 
