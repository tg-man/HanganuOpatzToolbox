%% Main Opto USV
% ramp section 

clear
experiments = get_experiment_redux;
experiments = experiments([259 260]); 
experiments = experiments(strcmp({experiments.square}, 'ACCdeep')); 

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
   
    % load stimulation properties
    load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
    ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp');
    % extract the end of all the ramps
    stim_ends = cat(1, StimulationProperties_raw{ramps,2});
    % convert to ms
    stim_ends = round(stim_ends / 3.2);

    % load USVs 
    load([experiment.USV_path experiment.USV]); 
    start = Calls.("Box")(1,1); % recording start 
    stop = Calls.('Box')(end,1) + Calls.("Box")(end,3); % recording end 
    usvmat = zeros(round((stop - start) * 1000), 1); % initialize 
    
    Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls
    timestamps = round((Calls.("Box")(:, 1) - start) * 1000); 
    timestamps(1) = []; 
    usvmat(timestamps) = 1; % where there's call  
    
    rampusvmat = zeros(size(stim_ends, 1), 10000);  % initialize 
    rampcalls = []; 
    for ramp = 1 : size(stim_ends, 1) 
        rampusvmat(ramp, :) = usvmat(stim_ends(ramp) - 5999 : stim_ends(ramp) + 4000);
        rampcalls = [rampcalls find(rampusvmat(ramp, :))]; 
    end 
    figure; hold on; 
    histogram(rampcalls, BinWidth = 500); 
    title([experiment.animal_ID ', P' num2str(experiment.age) ', E' num2str(experiment.IUEage) ', ' num2str(experiment.IUEconstruct)])
    xlabel('Time(ms)'); ylabel('# of calls, 30x ramps sum'); 
    xlim([1 10000]); xline(3000, ':k', 'Linewidth', 1.5); xline(6000, ':k', 'Linewidth', 1.5); 
    set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
end 

%%
% pulse section 

clear
experiments = get_experiment_redux;
experiments = experiments([259 260]); 
experiments = experiments(strcmp({experiments.square}, 'ACCdeep')); 

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
pulse2use = 15; % in ms 

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 
   
    % load stimulation properties
    load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
    pulses = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'constant');
    % extract the end of all the ramps
    StimulationProperties_raw = StimulationProperties_raw(pulses, :);
    StimulationProperties_raw = StimulationProperties_raw(ceil(cat(1, StimulationProperties_raw{:, 5}) * 1000) == pulse2use, :); 
    stim_starts = [StimulationProperties_raw{:, 1}]'; 
    stim_starts = round(stim_starts / 3.2); % convert to ms

    % load USVs 
    load([experiment.USV_path experiment.USV]); 
    start = Calls.("Box")(1,1); % recording start 
    stop = Calls.('Box')(end,1) + Calls.("Box")(end,3); % recording end 
    usvmat = zeros(round((stop - start) * 1000), 1); % initialize 
    Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls
    timestamps = round((Calls.("Box")(:, 1) - start) * 1000); 
    timestamps(1) = []; 
    usvmat(timestamps) = 1; % where there's call  
    
    pulseusvmat = zeros(size(stim_starts, 1), 2000);  % initialize 
    pulsecalls = []; 
    for pulse = 1 : size(stim_starts, 1) 
        pulseusvmat(pulse, :) = usvmat(stim_starts(pulse) - 999 : stim_starts(pulse) + 1000); 
        pulsecalls = [pulsecalls find(pulseusvmat(pulse, :))]; 
    end 
    figure; hold on; 
    histogram(pulsecalls, BinWidth = 50); 
    title([experiment.animal_ID ', P' num2str(experiment.age) ', E' num2str(experiment.IUEage) ', ' num2str(experiment.IUEconstruct)])
    xlabel('Time (ms)'); ylabel('# of calls, 50 pulses sum'); 
    xlim([0 2000]); xline(1000, ':k', 'Linewidth', 1.5); xline(1000 + pulse2use, ':k', 'Linewidth', 1.5); 
    set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
end 