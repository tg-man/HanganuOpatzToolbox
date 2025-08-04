%% Ramp STTC 

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
folder4om = 'Q:\Personal\Tony\Analysis\Results_OptoMatricesRamp\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';

% area names 
area = 'Str'; 

% params 
pre = [1401 2900]; % time stamp, assuming ramp matrics are 10000 long, 3000:6000 is ramp 
during = [4501 6000]; 
lags = [5, 10, 20, 50, 100, 500, 1000]; 
repeat_calc = 0;

% get unique animals 
animals = unique({experiments.animal_ID}); 

for animal_idx = 1 : numel(animals)
    disp(['computing... animal ' num2str(animal_idx) ' / ' num2str(numel(animals))])

    mouse = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % get all cell clusters ( in case different cells in all sessions) 
    cells = []; 
    for exp_idx = 1 : numel(exp4mouse)
        experiment = exp4mouse(exp_idx); 
        load([folder4sm area '\' experiment.name]);
        cells = union(cells, clusters);
        clearvars spike_matrix clusters 
    end 

    % ACC stim section 
    if ~exist([folder2save area '\ACCstim\' mouse '.mat']) || repeat_calc == 1
        % get all acc stim experiments 
        expacc = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'ACC'));
        % if there is at least one ACCstim exp, proceed 
        if numel(expacc) > 0
            % initialize opto matrics 
            om = []; 
            % loop to extract spikes 
            for exp_idx = 1 : numel(expacc)
                experiment = expacc(exp_idx); 
                % load and assign opto matrix area 1
                load([folder4sm area '\' experiment.name]); 
                clearvars spike_matrix; % only clusters variable is useful here 
                load([folder4om area '\' experiment.name]); 
                rampspikes = SUAdata_ramp.ramp_spike_matrix; 
                [~, loc] = ismember(clusters, cells);
                temp = zeros(size(rampspikes, 1), numel(cells), size(rampspikes, 3)); % initialize temp of the correct dimension 
                temp(:, loc, :) = rampspikes; 
                om = [om; temp]; 
                clearvars SUAdata_ramp rampspikes temp clusters 
            end 

            % set unrelevant period to zero (prepare for STTC calculation) 
            om_pre = om; 
            om_pre(:, :, [1:pre(1), pre(2):size(om, 3)]) = 0; 
            om_during = om; 
            om_during(:, :, [1:during(1), during(2):size(om, 3)]) = 0;
            % reshape, to have long 2D matrics 
            om_pre = permute(om_pre, [3 1 2]);
            om_pre = reshape(om_pre, size(om_pre, 1) * size(om_pre, 2), [])';
            om_during = permute(om_during, [3 1 2]);
            om_during = reshape(om_during, size(om_during, 1) * size(om_during, 2), [])';
            clearvars om

            % now calculate STTC (ACC stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells)
                    spike_times_1_pre = find(om_pre(unit1, :)) / 1000; % spike times in seconds 
                    N1v_pre = numel(spike_times_1_pre); % number of spikes 
                    spike_times_1_during = find(om_during(unit1, :)) / 1000; % spike times in seconds 
                    N1v_during = numel(spike_times_1_during); % number of spikes 
                    for unit2 = (unit1 + 1) : numel(cells)
                        spike_times_2_pre = find(om_pre(unit2, :)) / 1000; % spike times in seconds 
                        N2v_pre = numel(spike_times_2_pre); % number of spikes 
                        spike_times_2_during = find(om_during(unit2, :)) / 1000; % spike times in seconds 
                        N2v_during = numel(spike_times_2_during); % number of spikes 
                        % the calculation step 
                        STTC_pre(pair, lag_idx) = getSTTC(N1v_pre, N2v_pre, lag, [0 size(om_pre, 2)/1000], spike_times_1_pre, spike_times_2_pre);
                        STTC_during(pair, lag_idx) = getSTTC(N1v_during, N2v_during, lag, [0 size(om_during, 2)/1000], spike_times_1_during, spike_times_2_during);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampSTTC.pre = STTC_pre; 
            RampSTTC.during = STTC_during; 
            RampSTTC.lags = lags; 
            RampSTTC.note = [area ', ACC stim, sup and deep pooled']; 
            % save 
            if ~exist([folder2save area '\ACCstim\'], 'dir')
                mkdir([folder2save area '\ACCstim\'])
            end 
            save([folder2save area '\ACCstim\' mouse], 'RampSTTC')
            clearvars STTC_during STTC_pre RampSTTC om_during om_pre
        end % check expacc numel end 
    end % ACCstim block check end 


    % Str stim section 
    if ~exist([folder2save area '\Strstim\' mouse '.mat']) || repeat_calc == 1
        % get all str stim experiments 
        experiment = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'Str'));
        % if there is at least one Strstim exp, proceed 
        if numel(experiment) > 0 
            % load and assign opto matrices
            load([folder4sm area '\' experiment.name]); 
            clearvars spike_matrix; % only clusters variable is useful here 
            load([folder4om area '\' experiment.name]); 
            rampspikes = SUAdata_ramp.ramp_spike_matrix; 
            [~, loc] = ismember(clusters, cells);
            om = zeros(size(rampspikes, 1), numel(cells), size(rampspikes, 3)); % initialize om1 of the correct dimension 
            om(:, loc, :) = rampspikes; 
            clearvars SUAdata_ramp rampspikes temp clusters 

            % set irrelevant period to zero (prepare for STTC calculation) 
            om_pre = om; 
            om_pre(:, :, [1:pre(1), pre(2):size(om, 3)]) = 0; 
            om_during = om; 
            om_during(:, :, [1:during(1), during(2):size(om, 3)]) = 0;
            % reshape, to have long 2D matrics 
            om_pre = permute(om_pre, [3 1 2]);
            om_pre = reshape(om_pre, size(om_pre, 1) * size(om_pre, 2), [])';
            om_during = permute(om_during, [3 1 2]);
            om_during = reshape(om_during, size(om_during, 1) * size(om_during, 2), [])';
            clearvars om

            % now calculate STTC (ACC stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells)
                    spike_times_1_pre = find(om_pre(unit1, :)) / 1000; % spike times in seconds 
                    N1v_pre = numel(spike_times_1_pre); % number of spikes 
                    spike_times_1_during = find(om_during(unit1, :)) / 1000; % spike times in seconds 
                    N1v_during = numel(spike_times_1_during); % number of spikes 
                    for unit2 = (unit1 + 1) : numel(cells)
                        spike_times_2_pre = find(om_pre(unit2, :)) / 1000; % spike times in seconds 
                        N2v_pre = numel(spike_times_2_pre); % number of spikes 
                        spike_times_2_during = find(om_during(unit2, :)) / 1000; % spike times in seconds 
                        N2v_during = numel(spike_times_2_during); % number of spikes 
                        % the calculation step 
                        STTC_pre(pair, lag_idx) = getSTTC(N1v_pre, N2v_pre, lag, [0 size(om_pre, 2)/1000], spike_times_1_pre, spike_times_2_pre);
                        STTC_during(pair, lag_idx) = getSTTC(N1v_during, N2v_during, lag, [0 size(om_during, 2)/1000], spike_times_1_during, spike_times_2_during);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampSTTC.pre = STTC_pre; 
            RampSTTC.during = STTC_during; 
            RampSTTC.lags = lags; 
            RampSTTC.note = [area ', Str stim, sup and deep pooled']; 
            % save 
            if ~exist([folder2save area '\Strstim\'], 'dir')
                mkdir([folder2save area '\Strstim\'])
            end 
            save([folder2save area '\Strstim\' mouse], 'RampSTTC')
            clearvars STTC_during STTC_pre RampSTTC om_during om_pre
        end % check expstr end 
    end % Str stim block end 

end % animal loop end 


%% section to export 

% stimarea = 'ACC'; 
stimarea = 'Str'; 

% lag to take [5 10 20 50 100 500]
lag_idx = 5; 

% initialize 
T = []; 

for animal_idx = 1 : numel(animals) 

    mouse = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, stimarea)); 

    % get ACC stim values 
    if numel(exp4mouse) > 0
        % load and extract values 
        load([folder2save area '\' stimarea 'stim\' mouse]);         
        sttc_pre = RampSTTC.pre(:, lag_idx); 
        temp_pre = table(repmat({mouse}, [numel(sttc_pre), 1]), sttc_pre, repmat({'pre'}, [numel(sttc_pre), 1]), repmat(exp4mouse(1).IUEconstruct, [numel(sttc_pre), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
        sttc_during = RampSTTC.during(:, lag_idx); 
        temp_during = table(repmat({mouse}, [numel(sttc_during), 1]), sttc_during, repmat({'during'}, [numel(sttc_during), 1]), repmat(exp4mouse(1).IUEconstruct, [numel(sttc_during), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
        T = [T; temp_pre; temp_during]; 
        clearvars sttc_pre sttc_during temp_pre temp_during RampSTTC
    end % baseline check end  
end 

% save 
writetable(T, [folder2save area '\RampSTTCs_' area '_' stimarea 'stim.csv'], 'Delimiter', ',');


