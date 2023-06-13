clear
experiments = get_experiment_redux;
experiments = experiments([80:127]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
save_data = 1;
repeatCalc = 0;
folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_stim\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_3Probe_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_3Probe_OptoMatricesRamp_shift\';
BrainAreas = {'ACC','Str','TH3'};%{'ACC','PL','Str','TH3'};
pulses = {[0.005, 0.015, 0.050], [0.015, 0.050]}; 
StimAreas = {'ACCsup', 'Str', 'TH'};

%% compute/plot firing rate stuff 


for area_idx = 1 : numel(BrainAreas) % iterate through each brain area 
    % select experiments with correct targetting for this brain area
    BrainArea = BrainAreas{area_idx}; 
    disp(['plotting recording area ' BrainArea])
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
        exp_area = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
    elseif strcmp(BrainArea, 'Str')
        exp_area = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
    elseif strcmp(BrainArea, 'TH3')
        exp_area = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea(1:end-1)) & extractfield(experiments, 'target3') == 1); 
    end 
    
    % going through each stim area and plot 
    for stim_idx = 1 : numel(StimAreas) 
        StimArea = StimAreas{stim_idx}; % select the stim area
        disp(['plotting stim in ' StimArea])
        % select the pulse types given based on stim area
        if stim_idx == 1 || stim_idx == 2 
            pulse_length = pulses{1}; 
        else 
            pulse_length = pulses{2}; 
        end 
        % filter experiemnts list to get the ones with Brain Area Rec and Stim Area stim
        exp2run = exp_area(strcmp(extractfield(exp_area, 'ramp'), StimArea)| strcmp(extractfield(exp_area, 'square'), StimArea));
        if ~size(exp2run,2) == 0        
            plotRampFiringRateHenrik(exp2run, BrainArea, StimArea, [folder4matrix BrainArea '\'], folder4stim, folder4ramps);
%             plotRampFiringSigUnits(exp2run, BrainArea, StimArea, [folder4matrix BrainArea '\'], folder4stim, folder4ramps);
%             plotPulsesFiringRateHenrik(exp2run, BrainArea, StimArea, pulse_length, [folder4matrix BrainArea '\'], folder4stim, folder4pulses);
        else 
            disp(['there is no ' BrainArea ' recording with ' StimArea ' Stim!'])
        end 
    end 
end 


