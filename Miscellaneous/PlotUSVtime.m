%% Plot USV vs time 

clear
experiments = get_experiment_redux;
experiments = experiments([256:266]);  

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
        time2add = time2add + Calls.('Box')(end,1); 
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
        timestamps(:, 1) = Calls.('Box')(:,1); % extract beginning timestamps
        timestamps(:, 2) = exp_idx; 
        % concatenate timestamps to the vector
        % if the second experiment onwards, adjust timestamps values to continue from the first exp
        if exp_idx == 1 
            vec2plot = [vec2plot; timestamps]; 
        else 
            timestamps(:, 1) = timestamps(:, 1) +  time2add + 300; 
            vec2plot = [vec2plot; timestamps]; 
        end 
        clear timestamps
    end 
    figure; 
    for idx = 1 : exp_idx
        histogram(vec2plot(vec2plot(:,2) == idx), BinWidth = 180); hold on; 
    end 
    title(mouse); xlabel('Time(s)'); ylabel('# of calls'); 
    ylim([0 25]);  
end 