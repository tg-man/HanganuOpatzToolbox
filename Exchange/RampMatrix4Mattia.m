% generate ramp averaged matrices for Mattia 

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

folder4ramps = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\';
folder2save = 'Q:\Personal\Tony\forMattia\RampMatrices\'; 
folder4sm = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\';

area1 = 'ACC'; 
area2 = 'Str'; 

animals = unique({experiments.animal_ID});

for animal_idx = 1 : numel(animals) 
    mouse = animals{animal_idx};
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse));

     % set condition 
    if exp4mouse(1).IUEconstruct == 13 
        condition = 'inj'; 
    elseif isnan(exp4mouse(1).IUEconstruct)
        condition = 'ctrl'; 
    end 

    % ACC stim 
    expacc = exp4mouse(contains({exp4mouse.ramp}, 'ACC')); 
    % if there are acc stim experiments 
    if numel(expacc) > 0

        % get all cell clusters in area 1 (in case different cells in all sessions) 
        cells = []; 
        for exp_idx = 1 : numel(expacc)
            experiment = expacc(exp_idx); 
            load([folder4sm area1 '\' experiment.name]);
            cells = union(cells, clusters);
            clearvars spike_matrix clusters 
        end 
        % initialize ramp matrix to get area 1 matricese 
        RampMatrix = [];
        % loop through 
        for exp_idx = 1 : numel(expacc)
            experiment = expacc(exp_idx);
            % load spike matrix to get assignment location 
            load([folder4sm area1 '\' experiment.name]);
            [~, loc] = ismember(clusters, cells);
            clearvars spike_matrix clusters 
            % load ramp matrix and assign 
            load([folder4ramps area1 '\' experiment.name]); 
            temp = zeros(size(SUAdata_ramp.ramp_spike_matrix, 1), numel(cells), size(SUAdata_ramp.ramp_spike_matrix, 3)); % initialize temp of the correct dimension 
            temp(:, loc, :) = SUAdata_ramp.ramp_spike_matrix;
            RampMatrix = [RampMatrix; temp];
            clearvars SUAdata_ramp temp
        end 
        % average across ramps 
        RampMatrix = squeeze(nanmean(RampMatrix, 1));
        % save 
        if ~exist([folder2save 'ACCstim\' condition '\' area1 filesep], 'dir')
            mkdir([folder2save 'ACCstim\' condition '\' area1 filesep]);  
        end 
        save([folder2save 'ACCstim\' condition '\' area1 '\' experiment.animal_ID], 'RampMatrix')
        % clear some variables 
        clearvars RampMatrix cells loc 
    
        % get all cell clusters in area 2 (in case different cells in all sessions) 
        cells = []; 
        for exp_idx = 1 : numel(expacc)
            experiment = expacc(exp_idx); 
            load([folder4sm area2 '\' experiment.name]);
            cells = union(cells, clusters);
            clearvars spike_matrix clusters 
        end 
        % initialize ramp matrix to get area 2 matricese 
        RampMatrix = [];
        % loop through 
        for exp_idx = 1 : numel(expacc)
            experiment = expacc(exp_idx);
            % load spike matrix to get assignment location 
            load([folder4sm area2 '\' experiment.name]);
            [~, loc] = ismember(clusters, cells);
            clearvars spike_matrix clusters 
            % load ramp matrix and assign 
            load([folder4ramps area2 '\' experiment.name]); 
            temp = zeros(size(SUAdata_ramp.ramp_spike_matrix, 1), numel(cells), size(SUAdata_ramp.ramp_spike_matrix, 3)); % initialize temp of the correct dimension 
            temp(:, loc, :) = SUAdata_ramp.ramp_spike_matrix;
            RampMatrix = [RampMatrix; temp];
            clearvars SUAdata_ramp temp
        end 
        % average across ramps 
        RampMatrix = squeeze(nanmean(RampMatrix, 1));
        % save 
        if ~exist([folder2save 'ACCstim\' condition '\' area2 '\'], 'dir')
            mkdir([folder2save 'ACCstim\' condition '\' area2 '\']);  
        end 
        save([folder2save 'ACCstim\' condition '\' area2 '\' experiment.animal_ID], 'RampMatrix');
        % clear some variables 
        clearvars RampMatrix expacc experiment

    end % check acc stim experiment numel end 


    % Str stim 
    expstr = exp4mouse(contains({exp4mouse.ramp}, 'Str')); 
    % if there's a str stim experiment 
    if numel(expstr) > 0 
        % load area 1 spike matrix 
        load([folder4ramps area1 filesep expstr.name]); 
        RampMatrix = squeeze(nanmean(SUAdata_ramp.ramp_spike_matrix, 1)); 
        % save 
        if ~exist([folder2save 'Strstim\' condition '\' area1 '\'], 'dir')
            mkdir([folder2save 'Strstim\' condition '\' area1 '\']);  
        end 
        save([folder2save 'Strstim\' condition '\' area1 '\' expstr.animal_ID], 'RampMatrix');
        clearvars RampMatrix SUAdata_ramp
    
        % load area 2 spike matrix 
        load([folder4ramps area2 '\' expstr.name]); 
        RampMatrix = squeeze(nanmean(SUAdata_ramp.ramp_spike_matrix, 1)); 
        % save 
        if ~exist([folder2save 'Strstim\' condition '\' area2 '\'], 'dir')
            mkdir([folder2save 'Strstim\' condition '\' area2 '\']);  
        end 
        save([folder2save 'Strstim\' condition '\' area2 '\' expstr.animal_ID], 'RampMatrix');
        clearvars RampMatrix SUAdata_ramp loc 
    end % check str stim experiment end 

end 

