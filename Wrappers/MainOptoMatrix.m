
%% general stuff

clear
experiments = get_experiment_redux;
experiments = experiments([80:127]);
save_data = 1;
repeatCalc = 0; 
pulses = {[0.005, 0.015, 0.050], [0.015, 0.050]}; 
folder4SUAinfo = 'Q:\Personal\Tony\Analysis\Results_3Probe_SUAinfo\';
folder4SM = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\';

% brain areas
BrainAreas = {'ACC','Str','TH3'};%{'ACC','PL','Str','TH3'};

%% save all the spike matrices (generic, for pulses and for ramps)

% first get the stimulation properties from ONLY OPTO experiments 
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
getStimProperties(experiments, save_data, repeatCalc, folder4stim)

% loop through each area and each animal to get one spike matrix per
% recording (NOT per animal) 
for area_idx = 1 : numel(BrainAreas)     
    
    BrainArea = BrainAreas{area_idx}; %define brain area for this loop
    disp(['writing brain area ' BrainArea])
    
    % select experiments with correct targetting for this brain area
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH3')
        experiments2run = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea(1:end-1)) & extractfield(experiments, 'target3') == 1); 
    end
    
    % going through each experiment now 
    for exp_idx = 1 : numel(experiments2run) 
        experiment = experiments2run(exp_idx);
        disp(['writing exp #' num2str(exp_idx) ' out of ' num2str(numel(experiments2run))]) 
        
        % selecting pulse stim type 
        if strcmp(experiment.ramp, 'ACCsup') || strcmp(experiment.square, 'ACCsup') || strcmp(experiment.ramp, 'PLsup') || strcmp(experiment.square, 'PLsup') 
            pulse_length = pulses{1}; 
        else 
            pulse_length = pulses{2}; 
        end 
        
        resultsKlusta = [folder4SUAinfo BrainArea '\'];
        SM_output = [folder4SM BrainArea '\'];
        
        getSpikeMatrixHenrik(experiment, resultsKlusta, save_data, repeatCalc, SM_output); 
        % here it doesn't calculate the baseline experiments because no baseline experiment was put in!
       
%         getPulsesSpikeMatrix(experiment, save_data, repeatCalc, pulse_length, SM_output, folder4stim, BrainArea, folder4pulses);
        
        getRampsSpikeMatrix(experiment, save_data, BrainArea, SM_output, folder4stim, folder4ramps);                      
    end 
end 


