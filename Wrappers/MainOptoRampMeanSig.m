%% Average signal stim 

clear
experiments = get_experiment_redux;
experiments = experiments([74:175]);  % 177 180 185
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 87);
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), 'ACCsup'));
% experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));

folder4stim = 'Q:\Personal\Tony\Analysis\Results_3Probe_StimProp\'; 
ch2load = 17:32; 
cores = 6; 
ExtractMode = 1; 
save_data = 1; 
repeatCalc = 0; 

getStimProperties(experiments, save_data, repeatCalc, folder4stim)

for exp_idx = 1 : length(experiments) 
    experiment = experiments(exp_idx); % select experiemnt 
    
    % load and select stim properties 
    load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
    ramps = StimulationProperties_raw(strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp'), :);
    ramps = ramps(round(cell2mat(ramps(:, 5))) == 3, :); 
    ramp_end = round(cell2mat(ramps(:, 2)) ./ 3.2); % in ms
    load_start = ramp_end - 6000; % in ms 
    load_end = ramp_end + 4000;
    L = length(ramp_end); 
    
    % load LFP and select ramp segments 
    parfor (ch = ch2load, cores)  
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(ch), '.ncs'];
        [~, signal, fs_load] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs_load, [1 500]);
        signal = signal(1 : 32 : end); % downsampled to ms 

        % LFP, ch x time x ramp 
        for ramp_idx = 1 : L 
            LFP(ch - 16, :, ramp_idx) = signal(load_start(ramp_idx) : load_end(ramp_idx)); 
        end 
    end
    
    % load stim channels 
    file_to_load = [experiment.path, experiment.name, '\STIM1A.ncs'];
    [~, stim1A, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
    stim1A = stim1A(1 : 32 : end);
    file_to_load = [experiment.path, experiment.name, '\STIM1D.ncs'];
    [~, stim1D, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
    stim1D = stim1D(1 : 32 : end);
    for ramp_idx = 1 : L 
       LFP(17, :, ramp_idx) = stim1A(load_start(ramp_idx) : load_end(ramp_idx));  
       LFP(18, :, ramp_idx) = stim1D(load_start(ramp_idx) : load_end(ramp_idx));
    end
    
    % take out bad channels and average 
    bad_ch = intersect(ch2load, [experiment.NoisyCh, experiment.OffCh]);
    LFP(bad_ch,:,:) = NaN; 
    LFP = nanmedian(LFP, 3); 
    LFP(isnan(LFP)) = 0; 
    
    % plot 
    figure; hold on; set(gcf, 'position', [50, 50, 1500, 1000])
    for ch = 1: 16
        plot(LFP(ch, :) + 100*(ch-1)); 
    end 
    xlim([0 10000]);
    plot(100 * LFP(17,:) ./ max(LFP(17,:)) - 150); % scale stim channel 
    plot(100 * LFP(18,:) ./ max(LFP(18,:)) - 300);
    xline(3000); xline(6000); 
    title(experiment.animal_ID); 
    xlabel('Time (ms)');
end
    
    
    
    
    
  




            
            

