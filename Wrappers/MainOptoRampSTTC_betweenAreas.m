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
area1 = 'ACC'; 
area2 = 'Str'; % Str or TH

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
    cells_1 = []; 
    cells_2 = []; 
    for exp_idx = 1 : numel(exp4mouse)
        experiment = exp4mouse(exp_idx); 
        load([folder4sm area1 '\' experiment.name]);
        cells_1 = union(cells_1, clusters);
        clearvars spike_matrix clusters 
        load([folder4sm area2 '\' experiment.name]);
        cells_2 = union(cells_2, clusters);
        clearvars spike_matrix clusters 
    end 

    % ACC stim section 
    if ~exist([folder2save area1 area2 '\ACCstim\' mouse '.mat']) || repeat_calc == 1
        % get all acc stim experiments 
        expacc = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'ACC'));
        % if there is at least one ACCstim exp, proceed 
        if numel(expacc) > 0
            % initialize opto matrics 
            om1 = []; 
            om2 = []; 
            % loop to extract spikes 
            for exp_idx = 1 : numel(expacc)
                experiment = expacc(exp_idx); 
                % load and assign opto matrix area 1
                load([folder4sm area1 '\' experiment.name]); 
                clearvars spike_matrix; % only clusters variable is useful here 
                load([folder4om area1 '\' experiment.name]); 
                rampspikes = SUAdata_ramp.ramp_spike_matrix; 
                [~, loc] = ismember(clusters, cells_1);
                temp = zeros(size(rampspikes, 1), numel(cells_1), size(rampspikes, 3)); % initialize temp of the correct dimension 
                temp(:, loc, :) = rampspikes; 
                om1 = [om1; temp]; 
                clearvars SUAdata_ramp rampspikes temp clusters 
                % load and assign opto matrix area 2
                load([folder4sm area2 '\' experiment.name]); 
                clearvars spike_matrix; % only clusters variable is useful here 
                load([folder4om area2 '\' experiment.name]); 
                rampspikes = SUAdata_ramp.ramp_spike_matrix; 
                [~, loc] = ismember(clusters, cells_2);
                temp = zeros(size(rampspikes, 1), numel(cells_2), size(rampspikes, 3)); % initialize temp of the correct dimension 
                temp(:, loc, :) = rampspikes; 
                om2 = [om2; temp]; 
                clearvars SUAdata_ramp rampspikes temp clusters 
            end 

            % set unrelevant period to zero (prepare for STTC calculation) 
            om1_pre = om1; 
            om1_pre(:, :, [1:pre(1), pre(2):size(om1, 3)]) = 0; 
            om1_during = om1; 
            om1_during(:, :, [1:during(1), during(2):size(om1, 3)]) = 0;
            om2_pre = om2; 
            om2_pre(:, :, [1:pre(1), pre(2):size(om2, 3)]) = 0; 
            om2_during = om2; 
            om2_during(:, :, [1:during(1), during(2):size(om2, 3)]) = 0;
            % reshape, to have long 2D matrics 
            om1_pre = permute(om1_pre, [3 1 2]);
            om1_pre = reshape(om1_pre, size(om1_pre, 1) * size(om1_pre, 2), [])';
            om1_during = permute(om1_during, [3 1 2]);
            om1_during = reshape(om1_during, size(om1_during, 1) * size(om1_during, 2), [])';
            om2_pre = permute(om2_pre, [3 1 2]);
            om2_pre = reshape(om2_pre, size(om2_pre, 1) * size(om2_pre, 2), [])';
            om2_during = permute(om2_during, [3 1 2]);
            om2_during = reshape(om2_during, size(om2_during, 1) * size(om2_during, 2), [])'; 
            clearvars om1 om2

            % now calculate STTC (ACC stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells_1)
                    spike_times_1_pre = find(om1_pre(unit1, :)) / 1000; % spike times in seconds 
                    N1v_pre = numel(spike_times_1_pre); % number of spikes 
                    spike_times_1_during = find(om1_during(unit1, :)) / 1000; % spike times in seconds 
                    N1v_during = numel(spike_times_1_during); % number of spikes 
                    for unit2 = 1 : numel(cells_2)
                        spike_times_2_pre = find(om2_pre(unit2, :)) / 1000; % spike times in seconds 
                        N2v_pre = numel(spike_times_2_pre); % number of spikes 
                        spike_times_2_during = find(om2_during(unit2, :)) / 1000; % spike times in seconds 
                        N2v_during = numel(spike_times_2_during); % number of spikes 
                        % the calculation step 
                        STTC_pre(pair, lag_idx) = getSTTC(N1v_pre, N2v_pre, lag, [0 size(om1_pre, 2)/1000], spike_times_1_pre, spike_times_2_pre);
                        STTC_during(pair, lag_idx) = getSTTC(N1v_during, N2v_during, lag, [0 size(om1_during, 2)/1000], spike_times_1_during, spike_times_2_during);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampSTTC.pre = STTC_pre; 
            RampSTTC.during = STTC_during; 
            RampSTTC.lags = lags; 
            RampSTTC.note = 'ACC x Str, ACC stim, sup and deep pooled'; 
            % save 
            if ~exist([folder2save area1 area2 '\ACCstim\'], 'dir')
                mkdir([folder2save area1 area2 '\ACCstim\'])
            end 
            save([folder2save area1 area2 '\ACCstim\' mouse], 'RampSTTC')
            clearvars STTC_during STTC_pre RampSTTC om1_during om1_pre om2_during om2_pre
        end % check expacc numel end 
    end % ACCstim block check end 


    % Str stim section 
    if ~exist([folder2save area1 area2 '\Strstim\' mouse '.mat']) || repeat_calc == 1
        % get all str stim experiments 
        experiment = experiments(strcmp({experiments.animal_ID}, mouse) & contains({experiments.ramp}, 'Str'));
        % if there is at least one Strstim exp, proceed 
        if numel(experiment) > 0 
            % load and assign opto matrices
            load([folder4sm area1 '\' experiment.name]); 
            clearvars spike_matrix; % only clusters variable is useful here 
            load([folder4om area1 '\' experiment.name]); 
            rampspikes = SUAdata_ramp.ramp_spike_matrix; 
            [~, loc] = ismember(clusters, cells_1);
            om1 = zeros(size(rampspikes, 1), numel(cells_1), size(rampspikes, 3)); % initialize om1 of the correct dimension 
            om1(:, loc, :) = rampspikes; 
            clearvars SUAdata_ramp rampspikes temp clusters 
            % load and assign opto matrix area 2
            load([folder4sm area2 '\' experiment.name]); 
            clearvars spike_matrix; % only clusters variable is useful here 
            load([folder4om area2 '\' experiment.name]); 
            rampspikes = SUAdata_ramp.ramp_spike_matrix; 
            [~, loc] = ismember(clusters, cells_2);
            om2 = zeros(size(rampspikes, 1), numel(cells_2), size(rampspikes, 3)); % initialize temp of the correct dimension 
            om2(:, loc, :) = rampspikes; 
            clearvars SUAdata_ramp rampspikes temp clusters 

            % set irrelevant period to zero (prepare for STTC calculation) 
            om1_pre = om1; 
            om1_pre(:, :, [1:pre(1), pre(2):size(om1, 3)]) = 0; 
            om1_during = om1; 
            om1_during(:, :, [1:during(1), during(2):size(om1, 3)]) = 0;
            om2_pre = om2; 
            om2_pre(:, :, [1:pre(1), pre(2):size(om2, 3)]) = 0; 
            om2_during = om2; 
            om2_during(:, :, [1:during(1), during(2):size(om2, 3)]) = 0;
            % reshape, to have long 2D matrics 
            om1_pre = permute(om1_pre, [3 1 2]);
            om1_pre = reshape(om1_pre, size(om1_pre, 1) * size(om1_pre, 2), [])';
            om1_during = permute(om1_during, [3 1 2]);
            om1_during = reshape(om1_during, size(om1_during, 1) * size(om1_during, 2), [])';
            om2_pre = permute(om2_pre, [3 1 2]);
            om2_pre = reshape(om2_pre, size(om2_pre, 1) * size(om2_pre, 2), [])';
            om2_during = permute(om2_during, [3 1 2]);
            om2_during = reshape(om2_during, size(om2_during, 1) * size(om2_during, 2), [])'; 
            clearvars om1 om2

            % now calculate STTC (Str stim, ACC x Str) 
            for lag_idx = 1 : numel(lags)
                lag = lags(lag_idx) / 1000; % convert to seconds
                % reset pair index every lag loop 
                pair = 1; 
                % loop through pairs 
                for unit1 = 1 : numel(cells_1)
                    spike_times_1_pre = find(om1_pre(unit1, :)) / 1000; % spike times in seconds 
                    N1v_pre = numel(spike_times_1_pre); % number of spikes 
                    spike_times_1_during = find(om1_during(unit1, :)) / 1000; % spike times in seconds 
                    N1v_during = numel(spike_times_1_during); % number of spikes 
                    for unit2 = 1 : numel(cells_2)
                        spike_times_2_pre = find(om2_pre(unit2, :)) / 1000; % spike times in seconds 
                        N2v_pre = numel(spike_times_2_pre); % number of spikes 
                        spike_times_2_during = find(om2_during(unit2, :)) / 1000; % spike times in seconds 
                        N2v_during = numel(spike_times_2_during); % number of spikes 
                        % the calculation step 
                        STTC_pre(pair, lag_idx) = getSTTC(N1v_pre, N2v_pre, lag, [0 size(om1_pre, 2)/1000], spike_times_1_pre, spike_times_2_pre);
                        STTC_during(pair, lag_idx) = getSTTC(N1v_during, N2v_during, lag, [0 size(om1_during, 2)/1000], spike_times_1_during, spike_times_2_during);
                        pair = pair + 1; 
                    end 
                end 
            end 
            % put in a structure 
            RampSTTC.pre = STTC_pre; 
            RampSTTC.during = STTC_during; 
            RampSTTC.lags = lags; 
            RampSTTC.note = 'ACC x Str, Str stim, sup and deep pooled'; 
            % save 
            if ~exist([folder2save area1 area2 '\Strstim\'], 'dir')
                mkdir([folder2save area1 area2 '\Strstim\'])
            end 
            save([folder2save area1 area2 '\Strstim\' mouse], 'RampSTTC')
            clearvars STTC_during STTC_pre RampSTTC om1_during om1_pre om2_during om2_pre
        end % check expstr end 
    end % Str stim block end 

end % animal loop end 

%% section to export csv 

stimarea = 'ACC'; 
% stimarea = 'Str'; 

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
        load([folder2save area1 area2 '\' stimarea 'stim\' mouse]);         
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
writetable(T, [folder2save area1 area2 '\RampSTTCs_ACCStr_' stimarea 'stim.csv'], 'Delimiter', ',');


% % old and deprecated 
% for exp_idx = 1 : size(experiments, 2)
%     experiment  = experiments(exp_idx); 
%     disp(['computing experiment ' num2str(exp_idx) '... '])
% 
%     % check for area and targeting, then compute STTC
%     if strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area2, BrainArea2) 
%         if experiment.target1 == 1 && experiment.target2 == 1 
%             disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
%             getRampSTTC_ba(experiment, folder4OM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4OSTTC);
%         end     
%     elseif strcmp(experiment.Area1, BrainArea1) && strcmp(experiment.Area3, BrainArea2) 
%         if experiment.target1 ==1 && experiment.target3 ==1 
%             disp(['running exp ' num2str(exp_idx) ' / ' num2str(size(experiments, 2))])
%             getRampSTTC_ba(experiment, folder4OM, BrainArea1, BrainArea2, lags, repeat_calc, save_data, folder4OSTTC); 
%         end 
%     end 
% end 
% 
% %% plotting 
% 
% clear; 
% experiments = get_experiment_redux;
% experiments = experiments([300 301 324:420]);
% experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
% experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
% experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);
% 
% folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';
% 
% accstr_pre = []; 
% accstr_during = []; 
% accth_pre = []; 
% accth_during = []; 
% 
% for exp_idx = 1 : size(experiments, 2) 
%     experiment = experiments(exp_idx); 
%     % load ACC Str data 
%     if experiment.target2 == 1 
%         load([folder4OSTTC 'ACCStr\' experiment.name]); 
%         accstr_pre = [accstr_pre; RampSTTC.STTC_pre]; 
%         accstr_during = [accstr_during; RampSTTC.STTC_during]; 
%     end 
%     clear RampSTTC 
%     % load ACC TH data 
%     if experiment.target3 == 1 
%         load([folder4OSTTC 'ACCTH\' experiment.name]); 
%         accth_pre = [accth_pre; RampSTTC.STTC_pre]; 
%         accth_during = [accth_during; RampSTTC.STTC_during]; 
%         lags = RampSTTC.lags; 
%     end 
%     clear RampSTTC 
% end
% 
% for lag_idx = 3 : length(lags) 
%     
%     % ACC x Str 
%     % shift values to positive 
%     shift = abs(min([accstr_pre(:, lag_idx); accstr_during(:, lag_idx)])) + 0.0001; 
%     vec2plot = log10([accstr_pre(:, lag_idx), accstr_during(:, lag_idx)] + shift); % log10 not log!!!!! 
%     figure; hold on; 
%     violins = violinplot(vec2plot); 
%     ylabel('log10 of shifted STTC'); xticklabels({'pre', 'during'});
%     set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
%     title(['ACC-Str ' num2str(lags(lag_idx)*1000) 'ms lag']);
% 
%     % ACC x TH
%     % shift values to positive 
%     shift = abs(min([accth_pre(:, lag_idx); accth_during(:, lag_idx)])) + 0.0001; 
%     vec2plot = log10([accth_pre(:, lag_idx), accth_during(:, lag_idx)] + shift); % log10 not log!!!!! 
%     figure; hold on; 
%     violins = violinplot(vec2plot); 
%     ylabel('log10 of shifted STTC'); xticklabels({'pre', 'during'});
%     set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
%     title(['ACC-TH ' num2str(lags(lag_idx)*1000) 'ms lag']);
% end 

