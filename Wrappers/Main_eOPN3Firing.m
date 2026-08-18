

% filter experiments 
clear
experiments = get_experiment_redux;
experiments = experiments(557:end);

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
area = 'ACC'; 
% area = 'Str'; 

T = []; 

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % load spike matrix 
    load([folder4SM area '\' experiment.name]);

    % load stimulation properties 
    if isnan(experiment.ramp) && strcmp(experiment.square, 'Str')
        % load stim prop
        load([folder4stim experiment.name '_StimulationProperties_raw.mat']);

        % check stim paradigm and trim spike matrix 
        if experiment.laserpower > 4
            % all time stamps (in miliseconds after division by 3.2)
            starts = round(cell2mat(StimulationProperties_raw(:, 1)) / 3.2);
            stops = round(cell2mat(StimulationProperties_raw(:, 2)) / 3.2);
            % find stim breaks 
            lightsoff = find(diff(starts) > 290000); % find stim breaks
   
            % time stamps 
            start1 = stops(lightsoff(1)); 
            stop1 = starts(lightsoff(1) + 1); 
            start2 = stops(lightsoff(2));
            stop2 = starts(lightsoff(2) + 1); 

            % trim spike matrix 
            spike_matrix = spike_matrix(:, [start1:stop1 start2:stop2]);
            clearvars start1 stop1 start2 stop2

        elseif experiment.laserpower < 3 && size(StimulationProperties_raw, 1) == 1
             % all time stamps (in miliseconds after division by 3.2)
            start1 = round(cell2mat(StimulationProperties_raw(1, 1)) / 3.2); 
            stop1 = round(cell2mat(StimulationProperties_raw(1, 2)) / 3.2); 

            % trim spike matrix 
            spike_matrix = spike_matrix(:, [start1:stop1]);
            clearvars start1 stop1 
        end 
    end 

    mouse = string(experiment.animal_ID); 
    condition = strjoin([string(experiment.Exp_type), string(experiment.laserpower)]); 
    opsin = experiment.IUEconstruct; 
    duration = size(spike_matrix, 2) / 1000; 
    spikes = full(sum(sum(spike_matrix))); 
    fr = spikes / duration; 
    temp = table(mouse, condition, opsin, spikes, duration, fr);
    T = [T; temp]; 
end 

Tnew = T(:, {'mouse', 'opsin', 'condition','fr'});
Tnew.opsin = string(Tnew.opsin);
Tnew.opsin(ismissing(Tnew.opsin)) = "Ctrl";
Twide = unstack(Tnew, 'fr', 'condition', ...
    'GroupingVariables', {'mouse','opsin'});


figure; hold on
plot([1 2 3], ...
    [Twide.baselineOnly0(strcmp(Twide.opsin, 'Ctrl')) Twide.opto5(strcmp(Twide.opsin, 'Ctrl')) Twide.opto2_5(strcmp(Twide.opsin, 'Ctrl'))], ...
    'Color', [0.7 0.7 0.7], 'LineWidth', 1.5)
plot([1 2 3], ...
    [Twide.baselineOnly0(strcmp(Twide.opsin, '27')) Twide.opto5(strcmp(Twide.opsin, '27')) Twide.opto2_5(strcmp(Twide.opsin, '27'))], ...
    'Color', [1 0 0], 'LineWidth', 1.5)
xlim([0.8 3.2]); 
xticks([1 2 3])
xticklabels({'baseline', 'pulses', 'constant'}); 
ylabel('FR (Hz)')
title(area)

% signrank(baseline, stim)

% quick histogram of mouse age distribution 
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only')); 
control = experiments(isnan([experiments.IUEconstruct])); 
experiments = experiments([experiments.IUEconstruct] == 27); 
figure; 
subplot(121); 
histogram([experiments.age])
title('eOPN3'); 
xlabel('age'); 
ylabel('count')
subplot(122); 
histogram([control.age]); 
title('control'); 
xlabel('age'); 

