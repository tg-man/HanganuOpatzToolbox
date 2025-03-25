%% add recording duration to normalize 

%% sentence section 

clear; 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\rampUSVsentences_grouped.csv', 'Delimiter', ','); 

% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
post = 3000; % in miliseconds 

% initialize duration 
T.dur_s = NaN([size(T, 1), 1]); 

for idx = 1 : size(T, 1)
    animal = T.mouse(idx); 
    if T.condition(idx) == 0 
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));
        % get USV files and timestamps 
        load([exp4row.USV_path exp4row.USV]); 
        Calls = Calls(Calls.Accept, :);
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
            T.dur_s(idx) = round(Calls.Box(end, 1) - Calls.Box(1)); % in seconds 
        end
    elseif ~T.condition(idx) == 0
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
        for exp_idx = 1 : size(exp4row, 2)
            experiment = exp4row(exp_idx); 
            load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
            ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
            StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
            stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); 
            stim(end) = stim(end) + post; % add some post last ramp laser
            % add it 
            if isnan(T.dur_s(idx))
                temp = 0; 
            else 
                temp = T.dur_s(idx); 
            end 
            T.dur_s(idx) = temp + round((stim(end) - stim(1))/1000);  % in seconds 
            clear temp
        end 
    end 
end 

% calculate and save 
T.norm_0 = T.pure_0 ./ T.dur_s;
T.norm_1 = T.pure_1 ./ T.dur_s;
T.norm_mixed = T.mixed ./ T.dur_s;
T.norm_tot = (T.pure_0 + T.pure_1 + T.mixed) ./ T.dur_s;

writetable(T, 'Q:\Personal\Tony\Analysis\USV_csvs\rampUSVsentences_grouped_wNorm.csv', 'QuoteStrings', true);

%% isolated call section 

clear; 
T = readtable('Q:\Personal\Tony\Analysis\USV_csvs\rampUSVisocalls_grouped.csv', 'Delimiter', ','); 

% get experiments
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
post = 3000; % in miliseconds 

% initialize duration 
T.dur_s = NaN([size(T, 1), 1]); 

for idx = 1 : size(T, 1)
    animal = T.mouse(idx); 
    if T.condition(idx) == 0 
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));
        % get USV files and timestamps 
        load([exp4row.USV_path exp4row.USV]); 
        Calls = Calls(Calls.Accept, :);
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
            T.dur_s(idx) = round(Calls.Box(end, 1) - Calls.Box(1)); % in seconds 
        end
    elseif ~T.condition(idx) == 0
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
        for exp_idx = 1 : size(exp4row, 2)
            experiment = exp4row(exp_idx); 
            load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
            ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
            StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
            stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); 
            stim(end) = stim(end) + post; % add some post last ramp laser
            % add it 
            if isnan(T.dur_s(idx))
                temp = 0; 
            else 
                temp = T.dur_s(idx); 
            end 
            T.dur_s(idx) = temp + round((stim(end) - stim(1))/1000);  % in seconds 
            clear temp
        end 
    end 
end 

% save 
writetable(T, 'Q:\Personal\Tony\Analysis\USV_csvs\rampUSVisocalls_grouped_wNorm.csv', 'QuoteStrings', true);


%% all single call section 

clear; 
T1 = readtable('Q:\Personal\Tony\Analysis\USV_csvs\RampUSVcalltypes_stim.csv', 'Delimiter', ',');
T2 = readtable('Q:\Personal\Tony\Analysis\USV_csvs\RampUSVcalltypes_ctrl.csv', 'Delimiter', ',');
T = [T1; T2]; 

% save the concatenated table first 
writetable(T, 'Q:\Personal\Tony\Analysis\USV_csvs\rampUSVcalltypes.csv', 'QuoteStrings', true);

% get lists of experiments 
experiments = get_experiment_redux;
experiments = experiments(256:end);
experiments = experiments([experiments.target2] == 1);
experiments = experiments([experiments.DiI] == 0);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
post = 3000; % in miliseconds 

% initialize duration 
T.dur_s = NaN([size(T, 1), 1]); 

for idx = 1 : size(T, 1)
    animal = T.mouse(idx); 
    if T.condition(idx) == 0 
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));
        % get USV files and timestamps 
        load([exp4row.USV_path exp4row.USV]); 
        Calls = Calls(Calls.Accept, :);
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8
            T.dur_s(idx) = round(Calls.Box(end, 1) - Calls.Box(1)); % in seconds 
        end
    elseif ~T.condition(idx) == 0
        exp4row = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal) & strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
        for exp_idx = 1 : size(exp4row, 2)
            experiment = exp4row(exp_idx); 
            load([folder4stim experiment.name '_StimulationProperties_raw.mat']); 
            ramps = strcmp(StimulationProperties_raw(:, 8), 'ramp');
            StimulationProperties_raw = StimulationProperties_raw(ramps, :); 
            stim = round(cell2mat([StimulationProperties_raw(1, 1) StimulationProperties_raw(end ,2)]) / 3.2); 
            stim(end) = stim(end) + post; % add some post last ramp laser
            % add it 
            if isnan(T.dur_s(idx))
                temp = 0; 
            else 
                temp = T.dur_s(idx); 
            end 
            T.dur_s(idx) = temp + round((stim(end) - stim(1))/1000);  % in seconds 
            clear temp
        end 
    end 
end 

T.norm_0 = T.type0 ./ T.dur_s; 
T.norm_1 = T.type1 ./ T.dur_s; 
T.norm_tot = (T.type1 + T.type0) ./ T.dur_s; 

% save 
writetable(T, 'Q:\Personal\Tony\Analysis\USV_csvs\rampUSVcalltypes_wNorm.csv', 'QuoteStrings', true);
