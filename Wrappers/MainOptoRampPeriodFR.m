%% 
% looking at the firing rate during the entire ramp stimulation period 
% compared to baseline period 

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
experiments = experiments([experiments.DiI] == 0); 
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);

% get unique list of animals 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

folder4sm = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\ACC\'; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 

% initialize the final table for plotting 
T = table(repelem(animals, 2)', 'VariableNames', {'mouse'});
T.exp = repmat({'baseline'; 'opto'}, [length(animals), 1]);

for idx = 1 : size(T, 1)
    % select experiments 
    exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), T.mouse(idx))); 
    if strcmp(T.exp(idx), 'baseline') 
        exp4row = exp4row(strcmp({exp4row.Exp_type}, 'baseline only'));
    elseif strcmp(T.exp(idx), 'opto') 
        exp4row = exp4row(strcmp({exp4row.Exp_type}, 'opto'));
    end

    % check if there's actually such an experiment 
    if isempty(exp4row)
        T.fr(idx) = NaN; 
        T.age(idx) = NaN; 
    else 
        allspikes = 0; 
        dur = 0; 
        % loop through the exp4row variable 
        for j = 1 : size(exp4row, 2) 
            experiment = exp4row(j); 
            if strcmp(T.exp(idx), 'baseline') 
                % load spike matrix 
                load([folder4sm experiment.name '.mat'])
                allspikes = sum(sum(spike_matrix)); 
                dur = round(size(spike_matrix, 2) / 1000); % covert to seconds 
                clearvars spike_matrix clusters
            else 
                % load stim property and get spikes 
                load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
                ramps = StimulationProperties_raw(strcmp(StimulationProperties_raw(:, 8), 'ramp'), :);
                ramps = ramps(1:30, :);
                start = round(cell2mat(ramps(1, 1)) / 3.2); % in miliseconds 
                stop = round(cell2mat(ramps(end, 2)) / 3.2); % in miliseconds 
                % load spike matrix 
                load([folder4sm experiment.name '.mat'])
                allspikes = allspikes + sum(sum(spike_matrix(:, start:stop)));
                dur = dur + round((stop - start) / 1000); % convert to seconds 
                clearvars StimulationProperties_raw spike_matrix clusters
            end % if experiment condition end              
        end % experiment loop end
        T.fr(idx) = allspikes / dur;
        T.age(idx) = experiment.age;
    end % if empty experiment loop end  
end 

figure; violins = violinplot(full(T.fr), T.exp, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
%     violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
ylabel('Firing rate (Hz)'); 
set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
title('baseline vs. total ramp period', 'FontSize', 16, 'FontName', 'Arial');

signrank(full(T.fr(strcmp(T.exp, 'baseline'))), full(T.fr(strcmp(T.exp, 'opto'))))