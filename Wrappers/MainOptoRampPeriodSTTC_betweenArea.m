%% Main ramp period STTC 

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

% links 
folder4sm = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_RampPeriodSTTC\ACCStr\';

% lag 
lags = [5 10 20 50 100 500 1000]; 

% l
repeat_calc = 0;

% get unique animals 
animals = unique({experiments.animal_ID}); 
% animal loop 
for animal_idx = 1 : numel(animals)

    mouse = animals{animal_idx}; 
    disp(['computing... animal ' num2str(animal_idx) ' / ' num2str(numel(animals))])

    % get all cell clusters ( in case different cells in all sessions) 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 
    cells_1 = []; 
    cells_2 = []; 
    for exp_idx = 1 : numel(exp4mouse)
        experiment = exp4mouse(exp_idx); 
        load([folder4sm 'ACC\' experiment.name]);
        cells_1 = union(cells_1, clusters);
        clearvars spike_matrix clusters 
        load([folder4sm 'Str\' experiment.name]);
        cells_2 = union(cells_2, clusters);
        clearvars spike_matrix clusters 
    end 

    % ACC stim section 
    if ~exist([folder2save 'ACCstim\' mouse '.mat']) || repeat_calc == 1
        % get all acc stim experiments 
        expacc = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'ACC'));

        if numel(expacc) > 0
            % initialize concatenated spike matrices 
            sm1 = zeros(numel(cells_1), 0); % use 1 in first column to keep size consistent, cut out later 
            sm2 = zeros(numel(cells_2), 0); 
            % cut relevant period of spike matrices and assign them 
            for exp_idx = 1 : numel(expacc) 
                experiment = expacc(exp_idx); 
                % get ramp time stamps 
                load([folder4stim experiment.name '_StimulationProperties_raw.mat'])
                ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp') & cell2mat(StimulationProperties_raw(:, 7)) > 0;
                StimulationProperties_raw = StimulationProperties_raw(ramps, :);
                stimstart = round(cell2mat(StimulationProperties_raw(1, 1)) / 3.2); % stim props are in 3.2kHz; x10 to align to raw recording fs 
                stimend = round(cell2mat(StimulationProperties_raw(end, 2)) / 3.2); % stim props are in 3.2kHz; x10 to align to raw recording fs 
                clearvars StimulationProperties_raw 
                % load and assign ACC spike matrix 
                load([folder4sm 'ACC\' experiment.name]);
                spike_matrix = spike_matrix(:, stimstart : stimend); 
                [~, loc] = ismember(clusters, cells_1); % get cell location assignment 
                temp = zeros(numel(cells_1), size(spike_matrix, 2)); % initialize temp of the correct dimension 
                temp(loc, :) = spike_matrix; % assign spike matrtix 
                sm1 = [sm1, zeros(numel(cells_1), (exp_idx-1)*1000), temp]; % concatenate to sm1 with flexilbe zero pad
                clearvars temp spike_matrix clusters
                % load and assign Str spike matrix 
                load([folder4sm 'Str\' experiment.name]);
                spike_matrix = spike_matrix(:, stimstart : stimend); 
                [~, loc] = ismember(clusters, cells_2);% get cell location assignment 
                temp = zeros(numel(cells_2), size(spike_matrix, 2)); % initialize temp of the correct dimension 
                temp(loc, :) = spike_matrix; % assign spike matrtix 
                sm2 = [sm2, zeros(numel(cells_2), (exp_idx-1)*1000), temp]; % concatenate to sm1 with flexilbe zero pad
                clearvars temp spike_matrix clusters
            end 
        
            % now calculate STTC (ACC stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells_1)
                    spike_times_1 = find(sm1(unit1, :)) / 1000; % spike times in seconds 
                    N1v = numel(spike_times_1); % number of spikes 
                    for unit2 = 1 : numel(cells_2)
                        spike_times_2 = find(sm2(unit2, :)) / 1000; % spike times in seconds 
                        N2v = numel(spike_times_2);
                        % the calculation step 
                        STTC(pair, lag_idx) = getSTTC(N1v, N2v, lag, [0 size(sm1, 2)/1000], spike_times_1, spike_times_2);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampPeriodSTTC.STTC = STTC; 
            RampPeriodSTTC.lags = lags; 
            RampPeriodSTTC.note = 'ACC x Str, ACC stim, sup and deep pooled'; 
            % save 
            if ~exist([folder2save 'ACCstim\'], 'dir')
                mkdir([folder2save 'ACCstim\'])
            end 
            save([folder2save 'ACCstim\' mouse], 'RampPeriodSTTC')
            % clear variables 
            clearvars sm1 sm2 RampPeriodSTTC STTC
        end % check expacc numel end 
    end % ACC calculation block end


    % Str stim section 
    if ~exist([folder2save 'Strstim\' mouse '.mat']) || repeat_calc == 1
        % get str stim experiments 
        experiment = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'Str'));
        
        if numel(experiment) > 0 
            % get stimulation time stamps 
            load([folder4stim experiment.name '_StimulationProperties_raw.mat'])
            ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp') & cell2mat(StimulationProperties_raw(:, 7)) > 0;
            StimulationProperties_raw = StimulationProperties_raw(ramps, :);
            stimstart = round(cell2mat(StimulationProperties_raw(1, 1)) / 3.2); % stim props are in 3.2kHz; x10 to align to raw recording fs 
            stimend = round(cell2mat(StimulationProperties_raw(end, 2)) / 3.2); % stim props are in 3.2kHz; x10 to align to raw recording fs 
            clearvars StimulationProperties_raw 
            
            % load and cut ACC spike matrix 
            load([folder4sm 'ACC\' experiment.name]);
            spike_matrix = spike_matrix(:, stimstart:stimend);
            [~, loc] = ismember(clusters, cells_1); % get cell location assignment 
            sm1 = zeros(numel(cells_1), size(spike_matrix, 2)); % initialize sm1 of the correct dimension 
            sm1(loc, :) = spike_matrix; % assign spike matrtix 
            clear spike_matrix clusters
            % load and cut Str spike matrix 
            load([folder4sm 'Str\' experiment.name]);
            spike_matrix = spike_matrix(:, stimstart:stimend);
            [~, loc] = ismember(clusters, cells_2); % get cell location assignment 
            sm2 = zeros(numel(cells_2), size(spike_matrix, 2)); % initialize sm2 of the correct dimension 
            sm2(loc, :) = spike_matrix; % assign spike matrtix 
            clearvars spike_matrix clusters 
    
            % now calculate STTC (ACC stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells_1)
                    spike_times_1 = find(sm1(unit1, :)) / 1000; % spike times in seconds 
                    N1v = numel(spike_times_1); % number of spikes 
                    for unit2 = 1 : numel(cells_2)
                        spike_times_2 = find(sm2(unit2, :)) / 1000; % spike times in seconds 
                        N2v = numel(spike_times_2);
                        % the calculation step 
                        STTC(pair, lag_idx) = getSTTC(N1v, N2v, lag, [0 size(sm1, 2)/1000], spike_times_1, spike_times_2);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampPeriodSTTC.STTC = STTC; 
            RampPeriodSTTC.lags = lags; 
            RampPeriodSTTC.note = 'ACC x Str, terminal stim in Str'; 
            % save 
            if ~exist([folder2save 'Strstim\'], 'dir')
                mkdir([folder2save 'Strstim\'])
            end 
            save([folder2save 'Strstim\' mouse], 'RampPeriodSTTC')
            % clear variables 
            clearvars  sm1 sm2 RampPeriodSTTC STTC
        end % check experiment numel end 
    end % Str repeat_calc check end 

end

%% Exporting section for ACC-Str baseline STTC 
% run the first section first 

% filter experiments 
experiments = get_experiment_redux;
experiments = experiments(ismember({experiments.animal_ID}, animals));

% stimarea = 'ACC'; 
stimarea = 'Str'; 
experiments = experiments(contains({experiments.ramp}, stimarea) | strcmp({experiments.ramp}, 'NaN'));

% links 
folder4baseline = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCStr\'; 
% lag to take [5 10 20 50 100 500]
lag_idx = 5; 

% initialize 
T = []; 

for animal_idx = 1 : numel(animals) 

    mouse = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % get baseline values 
    if any(contains({exp4mouse.Exp_type}, 'baseline'))
        experiment = exp4mouse(contains({exp4mouse.Exp_type}, 'baseline'));
        load([folder4baseline experiment.name]); 
        sttc = Tcoeff.STTC(:, lag_idx); 
        temp = table(repmat({mouse}, [numel(sttc), 1]), sttc, repmat({'baseline'}, [numel(sttc), 1]), repmat(experiment.IUEconstruct, [numel(sttc), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
        T = [T; temp]; 
        clearvars sttc temp Tcoeff
    end % baseline check end 

    % get ACC stim values 
    if any(contains({exp4mouse.square}, stimarea))
        % set condition 
        condition = 'stim'; 
        % load and extract values 
        load([folder2save 'ACCstim\' mouse]);         
        sttc = RampPeriodSTTC.STTC(:, lag_idx); 
        temp = table(repmat({mouse}, [numel(sttc), 1]), sttc, repmat({condition}, [numel(sttc), 1]), repmat(experiment.IUEconstruct, [numel(sttc), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
        T = [T; temp]; 
        clearvars sttc temp RampPeriodSTTC
    end % baseline check end  
end 

% save 
writetable(T, [folder2save 'RampPeriodSTTCs_ACCStr_' stimarea 'stim.csv'], 'Delimiter', ',');



