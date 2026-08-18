%% Plotting response of opto stimulation 
% select stim type and brain areas to look at in the script before plotting function 
% everything else is taken care of by the plotting function 

clear;

% filter experiments to leave specific type of stim 
stim = 'ACC'; 
% stim = 'Str'; 

% which brain area to plot spikes for 
area = 'ACC'; 
% area = 'Str'; 

% which pulse duration to look at 
pulse2plot = 0.05; 

experiments = get_experiment_redux;
experiments = experiments(1:566);
% keep only opto experiments 
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto')); 
% get rid of experiments with more than 1 opsin 
for i = 1 : size(experiments, 2)
    experiment = experiments(i); 
    if length(experiment.IUEconstruct) == 1
        keep(i) = 1; 
    else
        keep(i) = 0; 
    end 
end 
experiments = experiments(logical(keep)); %[300 301 324:426]
% get rid of experiments with DiI  on optotrodes 
experiments = experiments([experiments.DiI] == 0); 
% keep only injection experiments 
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13 | isnan(extractfield(experiments, 'IUEconstruct')));
experiments = experiments(contains({experiments.ramp}, stim));
experiments = experiments([experiments.laserpower] < 10)

% useful paths 
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';


% ramp plotting 
[spikes_tot_r, allcells_r, mice_r, age_r] = plotRampSpikes(experiments, area, folder4matrix, folder4ramps);

% pulse plotting 
[spikes_tot_p, allcells_p, mice_p, age_p] = plotPulseSpikes(experiments, area, folder4matrix, folder4pulses, pulse2plot);

% % compute/plot firing rate stuff with separate deep or sum stim
% plotRampFiringComp(experiments, 'Str', 'TH', StimArea, folder4ramps)

%%  old version: where stim layers were looked at separately

clear

StimArea = 'ACCdeep'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 
BrainArea = 'ACC';%{'ACC','PL','Str','TH'};
layer = 'deep'; 

experiments = get_experiment_redux;
experiments = experiments([300 301 324:end]); % [300 301 324:448]
% experiments = experiments(strcmp(extractfield(experiments, 'sites'), '3site'));
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments(strcmp(extractfield(experiments, 'electrode1'), 'W241'));

% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 87);
experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 13);

experiments = experiments([experiments.DiI] == 0); 
% experiments = experiments([experiments.DiI] == 1); 

experiments = experiments(strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(strcmp(extractfield(experiments, 'Area1'), 'PL'));
% experiments = experiments([experiments.age]' == 9 | [experiments.age]' == 10);

experiments = experiments([experiments.IUEage] > 19); 

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';
folder4pulses = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';
folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\ACC\'; 
pulse_length = [0.005, 0.015, 0.050]; 
pulse2plot = 0.05; 


% compute/plot firing rate stuff     
% compare Str and TH firing rate here 
% plotRampFiringComp(experiments, 'Str', 'TH', StimArea, folder4ramps)

disp(['plotting recording area ' BrainArea])
if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
    experiments = experiments(strcmp(extractfield(experiments, 'Area1'), BrainArea) & extractfield(experiments, 'target1') == 1); 
elseif strcmp(BrainArea, 'Str')
    experiments = experiments(strcmp(extractfield(experiments, 'Area2'), BrainArea) & extractfield(experiments, 'target2') == 1);
elseif strcmp(BrainArea, 'TH')
    experiments = experiments(strcmp(extractfield(experiments, 'Area3'), BrainArea) & extractfield(experiments, 'target3') == 1); 
end 

disp(['plotting stim in ' StimArea])
% ramp plotting 
if ~size(experiments,2) == 0
    plotRampFiringRateHenrik(experiments, BrainArea, StimArea, [folder4matrix BrainArea '\'], folder4stim, folder4ramps);
%     plotRampFiringPie(experiments, BrainArea, StimArea, folder4ramps); 
%     plotRampFiringSigUnits(experiments, BrainArea, StimArea, [folder4matrix BrainArea '\'], folder4stim, folder4ramps);
    plotRampFiringLayer(experiments, BrainArea, StimArea, folder4suainfo, layer, [folder4matrix BrainArea '\'], folder4stim, folder4ramps);
else 
    disp(['there is no ' BrainArea ' recording with ' StimArea ' ramp stim!'])
end 

% pulse plotting 
if ~size(experiments,2) == 0
    plotPulsesFiringRate(experiments, BrainArea, StimArea, pulse_length, pulse2plot, [folder4matrix BrainArea '\'], folder4stim, folder4pulses);
    plotPulsesFiringLayer(experiments, BrainArea, StimArea, folder4suainfo, layer, pulse_length, [folder4matrix BrainArea '\'], folder4stim, folder4pulses); 
else
    disp(['there is no ' BrainArea ' recording with ' StimArea ' pulse stim!'])
end




