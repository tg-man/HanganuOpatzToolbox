
clear
experiments = get_experiment_redux;
experiments = experiments([80:127]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\';
folderPowRamps = 'Q:\Personal\Tony\Analysis\Results_3Probe_RampPower_3s\'; % getRampPower params needs to be adjusted accordingly! 
BrainAreas = {'ACC','Str','TH'};%{'ACC','PL','Str','TH3'};
stimArea = 'ACCsup';
CSCs = 1:48; 
cores = 4; 


%% compute/plot ramp power stuff

% getStimProperties(experiments, save_data, repeatCalc, folder4stim)

experiments = experiments(strcmp(extractfield(experiments, 'ramp'), stimArea)); 

for idx = 1 : numel(experiments)
    experiment = experiments(idx); 
    disp(['running experiment number ' num2str(idx) ' out of ' num2str(size(experiments, 2))])
    parfor (CSC = CSCs, cores) 
        getRampPower(experiment, CSC, save_data, repeatCalc, folder4stim, folderPowRamps);
    end 
end

plotRampPower(experiments, stimArea, BrainAreas, folderPowRamps)

%         plotRampSignal(experiment, CSC, save_data, repeatCalc, folder4stim, folderPowRamps); 

