%% First section, just calculate PSD for the entire ramp period 

clear; 

% filter experiments 
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

% useful paths 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folder2save = 'Q:\Personal\Tony\Analysis\Results_RampPeriodPower\'; 

save_data = 1; 
cores = 4; 

% signal loading params 
ch2load = 1:48; 
fs = 32000; % sampling rate from data
downsampling_factor = 160; % downsample for LFP analysis
ExtractMode = 1; % extract from neuralynx into matlab
length = 1; % signal length to for pre and post computation, in second
freq_filt = [0.1 500];

% pWelch params 
windowSize = 1;
overlap = 0.4;
nfft = 256;
maxFreq = 100;

% loop through experiments 
for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % for experiments that hasn't been calculated yet 
    if ~exist([folder2save experiment.name '.mat'])

        % load stim properties and extract timestamps 
        load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
        ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp') & cell2mat(StimulationProperties_raw(:, 7)) > 0;
        StimulationProperties_raw = StimulationProperties_raw(ramps, :);
        stimstart = cell2mat(StimulationProperties_raw(1, 1)) * 10; % stim props are in 3.2kHz; x10 to align to raw recording fs 
        stimend = cell2mat(StimulationProperties_raw(end, 2)) * 10; % stim props are in 3.2kHz; x10 to align to raw recording fs 
        clear StimulationProperties_raw 
    
        % load signal, filter, and compute pWelch for LFP
        disp(['computing ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
        parfor (channel = ch2load, cores) 
            file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
            [~, signal, fs] = load_nlx_Modes(file_to_load, ExtractMode, []);
            signal = signal(stimstart : (stimend + 3*fs)); % cut only ramp period + a bit post ramp 
            signal = ZeroPhaseFilter(signal, fs, freq_filt); % origianlly 0.1
            signal = signal(1 : downsampling_factor : end);
            [PSD(channel, :), freq(channel, :)] = pWelchSpectrum(signal, windowSize, overlap, nfft, fs/downsampling_factor, maxFreq); 
        end
    
        % build struct 
        RampPeriodPSD.PSD = PSD; 
        RampPeriodPSD.freq = freq(1, :); 
    
        % save data 
        if save_data == 1 
            if ~exist(folder2save, 'dir')
                mkdir(folder2save)
            end 
            save([folder2save experiment.name], 'RampPeriodPSD')
        end % save data check end 
       
        clear PSD freq

    end % if exist end 
end % experiment loop end 



%% 2nd section: 
% load PSD, average within mouse, SDR
% plot them with baseline, stim, and ctrl conditions 

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
experiments = experiments([experiments.DiI] == 0); 
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13 | isnan(extractfield(experiments, 'IUEconstruct')));

% useful paths 
folder4rampPSD = 'Q:\Personal\Tony\Analysis\Results_RampPeriodPower\'; 
folder4basePSD = 'Q:\Personal\Tony\Analysis\Results_PSD_pWelch\'; 

% get unique animal list 
animals = unique({experiments.animal_ID}); 

% initialize 
T = table('Size', [0, 5],...
    'VariableNames', {'Animal', 'condition', 'SDR1', 'SDR2', 'normSDR'}, ...
    'VariableTypes', {'string', 'double', 'double', 'double', 'double'});

% loop through animals 
for animal_idx = 1 : numel(animals)
    animal = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, animal));

    % check if there's baseline experiment
    % if so get SDR values 
    if any(contains({exp4mouse.Exp_type}, 'baseline only'))
        experiment = exp4mouse(contains({exp4mouse.Exp_type}, 'baseline only')); 
        load([folder4basePSD experiment.name]); 
        power_acc = mean(PSDpWelch.PSD(17:32, :)); 
        power_str = mean(PSDpWelch.PSD(1:16, :));
        % calculate SDR 
        SDR = getSDR(power_acc, power_str, freqs, []);
        normSDR = (SDR(1) - SDR(2)) / (SDR(1) + SDR(2));
        % set condition for baseline 
        condition = 0; 
        T = [T; table({animal}, condition, SDR(1), SDR(2), normSDR, 'VariableNames', {'Animal', 'condition', 'SDR1', 'SDR2', 'normSDR'})];
        clearvars SDR normSDR PSDpWelch condition
    end % check baselin experiment end 

    % check if there's opto experiments 
    % if so, get SDR values 
    if any(contains({exp4mouse.Exp_type}, 'opto'))
        optos = exp4mouse(contains({exp4mouse.Exp_type}, 'opto')); 

        % initialize power variable
        power_acc = []; 
        power_str = []; 
        % now loop through opto experiments 
        for exp_idx = 1 : size(optos, 2)
            experiment = optos(exp_idx); 
            % load PSD 
            load([folder4rampPSD experiment.name]); 
            % assign values for brain areas 
            power_acc = [power_acc; mean(RampPeriodPSD.PSD(17:32, :))]; 
            power_str = [power_str; mean(RampPeriodPSD.PSD(1:16, :))];
            freqs = RampPeriodPSD.freq; 
            clearvars RampPeriodPSD
        end % opto exp loop end 

        % in case more than 1 experiments, average power spectra 
        if size(optos, 2) > 1 
            power_acc = mean(power_acc); 
            power_str = mean(power_str); 
        end 

        % compute SDR 
        SDR = getSDR(power_acc, power_str, freqs, []);
        normSDR = (SDR(1) - SDR(2)) / (SDR(1) + SDR(2));

        % set condition, 1 = stim and 2 = ctrl 
        if experiment.IUEconstruct == 13
            condition = 1; 
        else 
            condition =2; 
        end 

        % put into final table 
        T = [T; table({animal}, condition, SDR(1), SDR(2), normSDR, 'VariableNames', {'Animal', 'condition', 'SDR1', 'SDR2', 'normSDR'})];

        clearvars SDR normSDR condition
    end % check opto experiments end 

end % animal loop end 

% make wide format table for plotting 
T_wide = unstack(T(:, {'Animal', 'condition', 'normSDR'}), 'normSDR', 'condition');  

% plot stim group 
figure; 
violins = violinplot([T_wide.x0, T_wide.x1]); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
hold on; 
plot([1.2 1.8], [T_wide.x0, T_wide.x1], 'k')
yline(0, ':k'); 
ylim([-1.03 1.03])
xticklabels({'Baseline', 'Stim'})
ylabel('Normalized SDR (A.U.)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title('ACC \rightarrow Str', 'FontWeight', 'normal')

% plot control group 
figure; 
violins = violinplot([T_wide.x0, T_wide.x2]); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
end
hold on; 
plot([1.2 1.8], [T_wide.x0, T_wide.x2], 'k')
yline(0, ':k'); 
ylim([-1.03 1.03])
xticklabels({'Baseline', 'Ctrl'})
ylabel('Normalized SDR (A.U.)')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2)
title('ACC \rightarrow Str', 'FontWeight', 'normal')


