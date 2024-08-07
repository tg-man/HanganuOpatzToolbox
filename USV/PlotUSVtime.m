%% Plot USV vs time 

clear
experiments = get_experiment_redux;
experiments = experiments([300 301 324:380]);  

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    mouse = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), mouse)); 

    vec2plot = []; 
    time2add = 0; 
    % going through each experiments of the animal 
    for exp_idx = 1 : size(experiments4mouse, 2)
        experiment = experiments4mouse(exp_idx); 
        load([experiment.USV_path experiment.USV]) 
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
        time2sub = Calls.('Box')(1,1); % get timestamps to substract 
        Calls.('Box')(:,1) = Calls.('Box')(:,1) - time2sub;
        Calls(1, :) = []; % get rid of first row - it is the beginning mark
        timestamps(:, 1) = Calls.('Box')(:,1) + time2add + 300; % extract beginning timestamps and pad
        timestamps(:, 2) = exp_idx; 
        vec2plot = [vec2plot; timestamps];  % concatenate timestamps to the plotting vector
        time2add = vec2plot(end, 1); % get recording length
        vec2plot(end, :) = []; 
        clear timestamps
    end 
    vec2plot(:, 1) = vec2plot(:, 1) - 300; % fix padding for the first iteration 
    figure; 
    for idx = 1 : exp_idx
        if strcmp(experiments4mouse(idx).square, 'NaN') 
            color = [0 0.4470 0.7410];
        elseif strcmp(experiments4mouse(idx).square, 'ACCsup') 
            color = [0.8500 0.3250 0.0980]; 
        elseif strcmp(experiments4mouse(idx).square, 'ACCdeep') 
            color = [0.4660 0.6740 0.1880]; 
        end 
        histogram(vec2plot(vec2plot(:,2) == idx), 'FaceColor', color, BinWidth = 180); hold on; 
    end 
    title([mouse ' P' num2str(experiment.age) ' E' num2str(experiment.IUEage) ' ' num2str(experiment.IUEconstruct)]); 
    legend({experiments4mouse.square}, 'Location', 'northwest'); 
    xlabel('Time(s)'); ylabel('# of calls'); 
end 

%% baseline USV with age 

clear
experiments = get_experiment_redux;
experiments = experiments([300 301 324:380]);  
experiments = experiments(strcmp({experiments.Exp_type}, 'baseline only'));
age = [experiments.age]; 
callfreq = []; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1: size(experiments, 2) 
    experiment = experiments(exp_idx); 

    % load USV file 
    load([experiment.USV_path experiment.USV]); 

    start = Calls.("Box")(1,1); % recording start 
    stop = Calls.('Box')(end,1) + Calls.("Box")(end,3); % recording ens 
    dur = (stop - start) / 60; % recording duration in minutes 
    callfreq = [callfreq; (sum(Calls.Accept) - 2) / dur]; 

end 

figure; violins = violinplot(callfreq, age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('calls / min'); set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
title('Calls during baseline', 'FontSize', 16, 'FontName', 'Arial');


%% ACCsup stim calls vs age. 

clear
experiments = get_experiment_redux;
experiments = experiments([300 301 324:380]);  
experiments = experiments(strcmp({experiments.square}, 'ACCsup'));
age = [experiments.age]; 
callfreq = []; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1: size(experiments, 2) 
    experiment = experiments(exp_idx); 

    % load USV file 
    load([experiment.USV_path experiment.USV]); 

    start = Calls.("Box")(1,1); % recording start 
    stop = Calls.('Box')(end,1) + Calls.("Box")(end,3); % recording ens 
    dur = (stop - start) / 60; % recording duration in minutes 
    callfreq = [callfreq; (sum(Calls.Accept) - 2) / dur]; 

end 

figure; violins = violinplot(callfreq, age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('calls / min'); set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
title('Calls during ACCsup stim', 'FontSize', 16, 'FontName', 'Arial');


%% ACCdeep stim calls vs age. 

clear
experiments = get_experiment_redux;
experiments = experiments([300 301 324:380]);  
experiments = experiments(strcmp({experiments.square}, 'ACCdeep'));
age = [experiments.age]; 
callfreq = []; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1: size(experiments, 2) 
    experiment = experiments(exp_idx); 

    % load USV file 
    load([experiment.USV_path experiment.USV]); 

    start = Calls.("Box")(1,1); % recording start 
    stop = Calls.('Box')(end,1) + Calls.("Box")(end,3); % recording ens 
    dur = (stop - start) / 60; % recording duration in minutes 
    callfreq = [callfreq; (sum(Calls.Accept) - 2) / dur]; 

end 

figure; violins = violinplot(callfreq, age, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]);
for idx = 1:size(violins, 2)
    violins(idx).ViolinColor = YlGnBu(round(100/8*idx),:);
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
xlabel('Age (P)'); ylabel('calls / min'); set(gca, 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out');
title('Calls during ACCdeep stim', 'FontSize', 16, 'FontName', 'Arial');

