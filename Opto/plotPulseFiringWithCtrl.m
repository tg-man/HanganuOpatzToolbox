function spikes = plotPulseFiringWithCtrl(experiments, folder4pulses, area)

% if stim type needs to be specific, experiments needs to be filtered beforehand 

spikes_tot = []

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); % select experiment 
    % load spike matrix 

end 

% set selection factor 

ctrl = (isnan([experiments.IUEconstruct]));
exp = (~isnan([experiments.IUEconstruct]));

end 