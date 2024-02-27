%% using z score to do it 
clear

StimArea = 'ACCdeep'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 
BrainArea = 'ACC';%{'ACC','PL','Str','TH'};
% layer = 'deep'; 

experiments = get_experiment_redux;
experiments = experiments(260);
% experiments = experiments(strcmp(extractfield(experiments, 'sites'), '3site'));
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
experiments = experiments(strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(strcmp(extractfield(experiments, 'Area1'), 'PL'));
% experiments = experiments([experiments.age]' == 9 | [experiments.age]' == 10);

folder4pulses = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';

pulse2plot = 0.050; 
map4plot = viridis(100);
Gwindow = gausswin(51, 5); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
spikes_tot = [];

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    
    load([folder4pulses BrainArea '\' experiment.name])

    if isfield(SUAdata_pulses, ['pulse_spike_matrix' num2str(pulse2plot*1000)])
        spikes_animal = SUAdata_pulses.(['pulse_spike_matrix' num2str(pulse2plot*1000)]);
        if ~isnan(spikes_animal) 
            if size(spikes_animal, 2) > 1 
                spikes_units = squeeze(mean(spikes_animal)); 
            else 
                spikes_units = squeeze(mean(spikes_animal))'; 
            end 
            spikes_tot = cat(1, spikes_tot, spikes_units); 
        end
    end

    spikes_ds = downsamp_convolve(spikes_units, Gwindow, 1); % only convolve here 
    spikes_ds = squeeze(mean(reshape(spikes_ds, size(spikes_units, 1), 5, []), 2)); % only downsample here

    zscored_ds= zscore(spikes_ds, [], 2);
    presp = max(zscored_ds(:, 100:110), [], 2) > 6; % which cells are pulse responsive 
    figure; 
    imagesc(linspace(-500, 1000, size(zscored_ds, 2)), 1:sum(presp), zscored_ds(presp,:)); hold on; 
    colormap(map4plot); xline(0, ':w'); xline(50, ':w'); xlim([-300 300]); 
    ylabel('Single units'); xlabel('Time (ms)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' pulse stim '])
    figure; 
    x = zscored_ds(~presp,:); 
    x_sorted = sort_peak_time(x, 10);
    imagesc(linspace(-500, 1000, size(zscored_ds, 2)), 1:(size(zscored_ds, 1) - sum(presp)), x(x_sorted, :)); hold on; 
    colormap(map4plot); xline(0, ':w'); xline(50, ':w'); xlim([-300 300]); 
    ylabel('Single units'); xlabel('Time (ms)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' pulse stim (non responsive units)'])

    % ramp section 
    load([folder4ramps BrainArea '\' experiment.name])
    ramp_spikes = squeeze(mean(SUAdata_ramp.ramp_spike_matrix, 1)); % averaged across trials 
    ramp_ds = squeeze(mean(reshape(ramp_spikes, size(ramp_spikes, 1), 100, []), 2)); 
    zscored_ramp = zscore(ramp_ds, [], 2); % zscore
    figure; 
    imagesc(linspace(-3, 7, size(zscored_ramp, 2)), 1:sum(presp), zscored_ramp(presp, :)); hold on
    colormap(map4plot); xline(0, ':w'); xline(3, ':w');
    ylabel('Single units'); xlabel('Time (s)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' ramp stim'])
    figure; 
    y = zscored_ramp(~presp,:); 
    y_sorted = sort_spike_trains(y);
    imagesc(linspace(-3, 7, size(zscored_ramp, 2)), 1:(size(ramp_ds, 1) - sum(presp)), y(y_sorted, :), [-1 3]); hold on
    colormap(map4plot); xline(0, ':w'); xline(3, ':w');
    ylabel('Single units'); xlabel('Time (s)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' ramp stim (non responsive units)'])
end

%% using signed rank test 
clear

StimArea = 'ACCdeep'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 
BrainArea = 'ACC'; %{'ACC','PL','Str','TH'};
% layer = 'deep'; 

experiments = get_experiment_redux;
experiments = experiments(260);
% experiments = experiments(strcmp(extractfield(experiments, 'sites'), '3site'));
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
experiments = experiments(strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(strcmp(extractfield(experiments, 'Area1'), 'PL'));

folder4pulses = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesPulse\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';

pulse2plot = 0.050; 
map4plot = viridis(100); 
Gwindow = gausswin(51, 5); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel 
spikes_tot = []; 
idx = 1; 

% generate a matrix of pre selection with a random interval beofore pulse
% start for each pulse 
pre_a = 445 - round(rand(50,1)*10); 
for pulse = 1 : 50
    pre_stim(pulse, :) = pre_a(pulse) : pre_a(pulse) + 49;
end 

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);

    animal{idx} = experiment.animal_ID;
    idx = idx +1;
    
    load([folder4pulses BrainArea '\' experiment.name])

    if isfield(SUAdata_pulses, ['pulse_spike_matrix' num2str(pulse2plot*1000)])
        spikes_animal = SUAdata_pulses.pulse_spike_matrix50;
        if ~isnan(spikes_animal) 
            if size(spikes_animal, 2) > 1 
                spikes_units = squeeze(mean(spikes_animal)); 
            else 
                spikes_units = squeeze(mean(spikes_animal))'; 
            end 
            spikes_tot = cat(1, spikes_tot, spikes_units); 
        end
    end

    for pulse = 1:50
        pre(pulse) = 
        pre = squeeze(sum(spikes_animal(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
    end 
    during = squeeze(sum(spikes_animal(:, :, stim), 3));








    spikes_ds = downsamp_convolve(spikes_units, Gwindow, 1); % only convolve here 
    spikes_ds = squeeze(mean(reshape(spikes_ds, size(spikes_units, 1), 5, []), 2)); % only downsample here

    zscored_ds= zscore(spikes_ds, [], 2);
    presp = max(zscored_ds(:, 100:110), [], 2) > 6; % which cells are pulse responsive 
    figure; 
    imagesc(linspace(-500, 1000, size(zscored_ds, 2)), 1:sum(presp), zscored_ds(presp,:)); hold on; 
    colormap(map4plot); xline(0, ':w'); xline(50, ':w'); xlim([-300 300]); 
    ylabel('Single units'); xlabel('Time (ms)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' pulse stim '])
    figure; 
    x = zscored_ds(~presp,:); 
    x_sorted = sort_peak_time(x, 10);
    imagesc(linspace(-500, 1000, size(zscored_ds, 2)), 1:(size(zscored_ds, 1) - sum(presp)), x(x_sorted, :)); hold on; 
    colormap(map4plot); xline(0, ':w'); xline(50, ':w'); xlim([-300 300]); 
    ylabel('Single units'); xlabel('Time (ms)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' pulse stim (non responsive units)'])

    % ramp section 
    load([folder4ramps BrainArea '\' experiment.name])
    ramp_spikes = squeeze(mean(SUAdata_ramp.ramp_spike_matrix, 1)); % averaged across trials 
    ramp_ds = squeeze(mean(reshape(ramp_spikes, size(ramp_spikes, 1), 100, []), 2)); 
    zscored_ramp = zscore(ramp_ds, [], 2); % zscore
    figure; 
    imagesc(linspace(-3, 7, size(zscored_ramp, 2)), 1:sum(presp), zscored_ramp(presp, :)); hold on
    colormap(map4plot); xline(0, ':w'); xline(3, ':w');
    ylabel('Single units'); xlabel('Time (s)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' ramp stim'])
    figure; 
    y = zscored_ramp(~presp,:); 
    y_sorted = sort_spike_trains(y);
    imagesc(linspace(-3, 7, size(zscored_ramp, 2)), 1:(size(ramp_ds, 1) - sum(presp)), y(y_sorted, :), [-1 3]); hold on
    colormap(map4plot); xline(0, ':w'); xline(3, ':w');
    ylabel('Single units'); xlabel('Time (s)')
    set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
    title([BrainArea ' to ' StimArea ' ramp stim (non responsive units)'])
end


