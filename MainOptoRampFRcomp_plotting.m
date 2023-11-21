%% Plot 

clear

StimArea = 'ACCsup'; %{'ACCsup', 'PLsup', 'Str', 'TH'}; 

experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments((extractfield(experiments, 'IUEconstruct')) == 59);
% experiments = experiments(isnan(extractfield(experiments, 'IUEconstruct')));
experiments = experiments(strcmp(extractfield(experiments, 'square'), StimArea));
% experiments = experiments(strcmp(extractfield(experiments, 'Area1'), 'PL'));
% experiments = experiments([experiments.age]' == 9 | [experiments.age]' == 10);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';
folder4matrix = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';
folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';

map4plot = viridis(100);
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
save_data = 1;
pre_stim = 1 : 3000; % in ms, ramp format
stim = 3001 : 6000; % in ms, ramp format
post_stim = 6001 : 9000; % in ms, ramp format
idx = 1;

spikes_tot_str = [];
firing_tot_str = [];
OMI_str = [];
OMIpost_str = [];
pvalue_str = [];
pvalue_post_str = [];

spikes_tot_th = [];
firing_tot_th = [];
OMI_th = [];
OMIpost_th = [];
pvalue_th = [];
pvalue_post_th = [];

for n_animal = 1 : length(experiments)
    experiment = experiments(n_animal);
    animal{idx} = experiment.animal_ID;
    idx = idx +1;

    if experiment.target2 == 1         
        SUAdata = getRampsSpikeMatrix(experiment, save_data, 0, 'Str', folder4matrix, folder4stim, folder4ramps);
        spikes_animal_str = SUAdata.ramp_spike_matrix;

        % first concatenate the spike tensor into a matrix
        spikes_convolved_str = reshape(permute(spikes_animal_str, [2 3 1]), size(spikes_animal_str, 2), []);

         % convolve it with a gaussian window for better corr estimation
        for unit = 1 : size(spikes_convolved_str, 1)
            spikes_convolved_str(unit, :) = conv(spikes_convolved_str(unit, :), Gwindow, 'same');
        end
         % reshape it back so that you have separated trials
        spikes_convolved_str = permute(reshape(spikes_convolved_str, size(spikes_animal_str, 2), size(spikes_animal_str, 3), []), [3 1 2]);

        if numel(spikes_animal_str) > 0
            if size(spikes_animal_str, 2) > 1
                spikes_units_str = squeeze(mean(spikes_animal_str));
            else
                spikes_units_str = squeeze(mean(spikes_animal_str))';
            end
            firing_units_str(:, 1) = log10(mean(spikes_units_str(:, pre_stim), 2));
            firing_units_str(:, 2) = log10(mean(spikes_units_str(:, stim), 2));
            firing_units_str(:, 3) = log10(mean(spikes_units_str(:, post_stim), 2));
            spikes_tot_str = cat(1, spikes_tot_str, spikes_units_str);
            firing_tot_str = cat(1, firing_tot_str, firing_units_str);
            pre_str = squeeze(sum(spikes_animal_str(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
            during_str = squeeze(sum(spikes_animal_str(:, :, stim), 3));
            post_str = squeeze(sum(spikes_animal_str(:, :, post_stim), 3));
            OMI_animal_str = nanmean((during_str - pre_str) ./ (during_str + pre_str)); % compute modulation index
            OMI_animal_post_str = nanmean((post_str - pre_str) ./ (post_str + pre_str)); % compute modulation index
            pvalue_animal_str = zeros(1, size(pre_str, 2)); % preallocate
            pvalue_animal_post_str = zeros(1, size(pre_str, 2)); % preallocate
            for unit = 1 : size(pre_str, 2)
                pvalue_animal_str(unit) = signrank(pre_str(:, unit), during_str(:, unit)); % compute pvalue of "modulation index"
                pvalue_animal_post_str(unit) = signrank(pre_str(:, unit), post_str(:, unit)); % compute pvalue of "modulation index"
            end
            OMI_str = horzcat(OMI_str, OMI_animal_str); % concatenate
            pvalue_str = horzcat(pvalue_str, pvalue_animal_str); % concatenate
            OMIpost_str = horzcat(OMIpost_str, OMI_animal_post_str); % concatenate
            pvalue_post_str = horzcat(pvalue_post_str, pvalue_animal_post_str); % concatenate
            clear firing_units_str
        end
        clearvars spikes_animal_str
    end 

    if experiment.target3 == 1 
        SUAdata = getRampsSpikeMatrix(experiment, save_data, 0, 'TH', folder4matrix, folder4stim, folder4ramps);
        spikes_animal_th = SUAdata.ramp_spike_matrix;
        spikes_convolved_th = reshape(permute(spikes_animal_th, [2 3 1]), size(spikes_animal_th, 2), []);
        for unit = 1 : size(spikes_convolved_th, 1)
            spikes_convolved_th(unit, :) = conv(spikes_convolved_th(unit, :), Gwindow, 'same');
        end 
        spikes_convolved_th = permute(reshape(spikes_convolved_th, size(spikes_animal_th, 2), size(spikes_animal_th, 3), []), [3 1 2]);
    
        if numel(spikes_animal_th) > 0
            if size(spikes_animal_th, 2) > 1
                spikes_units_th = squeeze(mean(spikes_animal_th));
            else
                spikes_units_th = squeeze(mean(spikes_animal_th))';
            end
            firing_units_th(:, 1) = log10(mean(spikes_units_th(:, pre_stim), 2));
            firing_units_th(:, 2) = log10(mean(spikes_units_th(:, stim), 2));
            firing_units_th(:, 3) = log10(mean(spikes_units_th(:, post_stim), 2));
            spikes_tot_th = cat(1, spikes_tot_th, spikes_units_th);
            firing_tot_th = cat(1, firing_tot_th, firing_units_th);
            pre_th = squeeze(sum(spikes_animal_th(:, :, pre_stim), 3)); % summing up all the spikes in pre_stim period
            during_th = squeeze(sum(spikes_animal_th(:, :, stim), 3));
            post_th = squeeze(sum(spikes_animal_th(:, :, post_stim), 3));
            OMI_animal_th = nanmean((during_th - pre_th) ./ (during_th + pre_th)); % compute modulation index
            OMI_animal_post_th = nanmean((post_th - pre_th) ./ (post_th + pre_th)); % compute modulation index
            pvalue_animal_th = zeros(1, size(pre_th, 2)); % preallocate
            pvalue_animal_post_th = zeros(1, size(pre_th, 2)); % preallocate
            for unit = 1 : size(pre_th, 2)
                pvalue_animal_th(unit) = signrank(pre_th(:, unit), during_th(:, unit)); % compute pvalue of "modulation index"
                pvalue_animal_post_th(unit) = signrank(pre_th(:, unit), post_th(:, unit)); % compute pvalue of "modulation index"
            end
            OMI_th = horzcat(OMI_th, OMI_animal_th); % concatenate
            pvalue_th = horzcat(pvalue_th, pvalue_animal_th); % concatenate
            OMIpost_th = horzcat(OMIpost_th, OMI_animal_post_th); % concatenate
            pvalue_post_th = horzcat(pvalue_post_th, pvalue_animal_post_th); % concatenate
            clear firing_units_th
        end
        clearvars spikes_animal_th
    end 
end

spikes_reduced_str = squeeze(mean(reshape(spikes_tot_str, size(spikes_tot_str, 1), 100, []), 2));
spikes_reduced_th = squeeze(mean(reshape(spikes_tot_th, size(spikes_tot_th, 1), 100, []), 2));

figure; hold on; 
boundedline(linspace(0, 10, size(spikes_reduced_th, 2)), mean(spikes_reduced_th), std(spikes_reduced_th) ./ sqrt(size(spikes_reduced_th, 1)), 'cmap', [0.4660 0.6740 0.1880]); 
boundedline(linspace(0, 10, size(spikes_reduced_str, 2)), mean(spikes_reduced_str), std(spikes_reduced_str) ./ sqrt(size(spikes_reduced_str, 1))); 
xline(3, '--k', 'linewidth', 2) % reference line for opto
xline(6, '--k', 'linewidth', 2) % reference line for opto
ylabel('average FR (Hz)'); xlabel('Time (s)');
%ylim([0 0.0006])
legend('', 'TH', '', 'Str', '', '')
set(gca, 'TickDir', 'out', 'FontSize', 20, 'FontName', 'Arial', 'YScale', 'log', 'LineWidth', 2.8);
xticks([0 3 6 9]); 
xticklabels([-3 0 3 6])

lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2.8;
end


