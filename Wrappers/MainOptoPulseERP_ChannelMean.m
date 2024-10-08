%% To get pulse ERP

clear; 
experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );
pulse_length = 50; % in ms 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder4pulseERP = 'Q:\Personal\Tony\Analysis\Results_PulseERP\ChannelMean\'; 
% loading and filtering variables
fs = 32000; % sampling rate from data
downsampling_factor = 32; % downsample for LFP analysis
fs_LFP = fs / downsampling_factor;
high_cut = fs_LFP / 2; % nyquist frequency: the number of data points per second. Max high cut should be half of sampling frequency
stim_adjust = 1000 / fs_LFP; % to adjust stim timestamps to the same fs as LFP 
ExtractMode = 1; % extract from neuralynx into matlab
cores = 6;  

for exp_idx = 1 : size(experiments, 2) 
    experiment = experiments(exp_idx); 

    % load signal and take out bad channels
    disp(['loading signal exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2) )])
    if strcmp(experiment.sites, '2site')
        ch2load = 1:32; 
    elseif strcmp(experiment.sites, '3site')
        ch2load = 1:48;
    end 
    parfor (channel = ch2load, cores)
        file_to_load = [experiment.path, experiment.name, '\CSC', num2str(channel), '.ncs'];
        [~, signal, ~] = load_nlx_Modes(file_to_load, ExtractMode, []);
        signal = ZeroPhaseFilter(signal, fs, [0.5 high_cut]); % origianlly 0.1
        LFP(channel, :) = signal(1 : downsampling_factor : end); 
    end 
    bad_ch = [experiment.NoisyCh,experiment.OffCh]; 
    bad_ch = rmmissing(bad_ch(ismember(bad_ch, ch2load))); 
    LFP(bad_ch, :) = NaN; % Do the same here for noisy channels

    % load stimulation properties and extract pulses of desired length 
    load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
    StimulationProperties_raw = StimulationProperties_raw(strcmp(StimulationProperties_raw(:, 8), 'constant'), :);
    StimulationProperties_raw = StimulationProperties_raw(ceil(cell2mat(StimulationProperties_raw(:, 5))*1000) == pulse_length, :);
    stim_start = round(cell2mat(StimulationProperties_raw(:, 1)) ./ (3.2 * stim_adjust) ); % dvided by 3.2 to set to ms  
    
    % generate pulse LFP matrix, 500ms around the pulse, channel x time x pulse
    for pulse_idx = 1 : size(stim_start, 1)
        pulseLFP(:, :, pulse_idx) = LFP(:, (stim_start(pulse_idx) - fs_LFP/4 + 1) : (stim_start(pulse_idx) + fs_LFP/4));  
    end
    
    % exclude missed targetting 
    if experiment.target2 == 0
        pulseLFP(1 : 16, :, :) = NaN; 
    end 
    if experiment.target3 == 0 || isnan(experiment.target3) 
        pulseLFP(33 : 48, :, :) = NaN; 
    end 

    pulseLFP_acc = pulseLFP(17 : 32, :, :); 
    pulseLFP_str = pulseLFP(1 : 16, :, :); 
    pulseLFP_th= pulseLFP(33 : 48, :, :); 
    clear LFP pulseLFP 
    
    % substract baseline
    pulseLFP_acc = pulseLFP_acc- nanmedian(pulseLFP_acc(:,1:end/2,:),2);
    pulseLFP_str = pulseLFP_str - nanmedian(pulseLFP_str(:,1:end/2,:),2);
    pulseLFP_th = pulseLFP_th - nanmedian(pulseLFP_th(:,1:end/2,:),2);

    % average across channels 
    pulseLFP_acc = squeeze(nanmean(pulseLFP_acc, 1)); 
    pulseLFP_str = squeeze(nanmean(pulseLFP_str, 1)); 
    pulseLFP_th = squeeze(nanmean(pulseLFP_th, 1)); 

    % plotting
    if experiment.IUEconstruct == 59
        color = 'r'; 
    elseif experiment.IUEconstruct == 87
        color = 'g'; 
    elseif isnan(experiment.IUEconstruct)
        color = 'b'; 
    end 

    f = figure; hold on;
    for pulse_idx = 1 : size(stim_start, 1)
        subplot(311); hold on 
        h = plot(pulseLFP_acc(:, pulse_idx)); 
        h.Color = 'k'; h.Color(4) = 0.05;
        subplot(312); hold on
        h = plot(pulseLFP_str(:, pulse_idx)); 
        h.Color = 'k'; h.Color(4) = 0.05;
        subplot(313); hold on 
        h = plot(pulseLFP_th(:, pulse_idx)); 
        h.Color = 'k'; h.Color(4) = 0.05;
    end 

    subplot(311);
    h = plot(nanmedian(pulseLFP_acc, 2)); h.Color = color; 
    subplot(312);
    h = plot(nanmedian(pulseLFP_str, 2)); h.Color = color; 
    subplot(313);
    h = plot(nanmedian(pulseLFP_th, 2)); h.Color = color; 

    f.Position = [80+exp_idx*5 80+exp_idx*5 400 450]; 
    subplot(311); ylim([-400 100]); xlim([0 500]); 
    title('ACC'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); ylabel('ERP (microV)'); 
    subplot(312); ylim([-180 100]); xlim([0 500]); 
    title('Str'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); ylabel('ERP (microV)'); 
    subplot(313); ylim([-180 100]); xlim([0 500]); 
    title('TH'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); xlabel('time (ms)'); ylabel('ERP (microV)'); 
    sgtitle(experiment.animal_ID);
    saveas(gcf, fullfile(folder4pulseERP, experiment.name)); 
end