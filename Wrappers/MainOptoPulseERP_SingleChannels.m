%% To get pulse ERP

clear; 
experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 59 );
pulse_length = 50; % in ms 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder4pulseERP = 'Q:\Personal\Tony\Analysis\Results_PulseERP\SingleChannels\'; 
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

    % plotting
    if experiment.IUEconstruct == 59
        color = 'r'; 
    elseif experiment.IUEconstruct == 87
        color = 'g'; 
    elseif isnan(experiment.IUEconstruct)
        color = 'b'; 
    end 

    f = figure; hold on;
    for ch_idx = 1: 16 
        for pulse_idx = 1 : size(stim_start, 1)
            subplot(131); hold on 
%             h = plot(pulseLFP_acc(ch_idx, :, pulse_idx) - nanmedian(pulseLFP_acc(ch_idx, :, pulse_idx)) + 300 * (ch_idx - 1)); 
            h = plot(pulseLFP_acc(ch_idx, :, pulse_idx) + 300 * (ch_idx - 1)); 
            h.Color = 'k'; h.Color(4) = 0.05;
            subplot(132); hold on
            h = plot(pulseLFP_str(ch_idx, :, pulse_idx) + 300 * (ch_idx - 1)); 
            h.Color = 'k'; h.Color(4) = 0.05;
            subplot(133); hold on 
            h = plot(pulseLFP_th(ch_idx, :, pulse_idx) + 300 * (ch_idx - 1)); 
            h.Color = 'k'; h.Color(4) = 0.05;
        end 
        subplot(131);
        h = plot(nanmedian(squeeze(pulseLFP_acc(ch_idx, :, :)), 2) + 300 * (ch_idx - 1)); h.Color = color; 
        subplot(132);
        h = plot(nanmedian(squeeze(pulseLFP_str(ch_idx, :, :)), 2) + 300 * (ch_idx - 1)); h.Color = color; 
        subplot(133);
        h = plot(nanmedian(squeeze(pulseLFP_th(ch_idx, :, :)), 2) + 300 * (ch_idx - 1)); h.Color = color; 
    end

    f.Position = [80+exp_idx*5 80+exp_idx*5 700 650]; 
    subplot(131); ylim([-400 4700]); xlim([0 500]); 
    title('ACC'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); xlabel('time (ms)'); ylabel('ERP (microV + 300 offset per channel)'); 
    subplot(132); ylim([-400 4700]); xlim([0 500]); 
    title('Str'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); xlabel('time (ms)');
    subplot(133); ylim([-400 4700]); xlim([0 500]); 
    title('TH'); xline(fs_LFP/4, ':'); xline(fs_LFP/4 + pulse_length, ':'); xlabel('time (ms)');
    sgtitle(experiment.animal_ID);
    saveas(gcf, fullfile(folder4pulseERP, experiment.name)); 
end