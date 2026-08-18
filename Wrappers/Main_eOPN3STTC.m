
% filter experiments 
clear
experiments = get_experiment_redux;
experiments = experiments(557:end);
experiments = experiments(strcmp({experiments.Exp_type}, 'opto')); 

repeat_calc = 0; 
save_data = 1; 

folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_eOPN3sttc\'; 
folder4baselinesttc = 'Q:\Personal\Tony\Analysis\Results_STTC\';

area1 = 'ACC'; 
area2 = 'Str'; 

% lag 
lags = [5 10 20 50 100 500 1000]; 

% for exporting csv later
lag2use = 500; 
% lag2use = 100; 

% loop and compute experiment by experiment 
for exp_idx = 1 : numel(experiments)
    tic
    experiment = experiments(exp_idx); 

    % check if things already exist 
    if ~(repeat_calc == 0 && exist([folder2save area1 area2 '\' experiment.name '.mat'], 'file'))
        disp(['computing ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
    
        % load spike matrix 
        sm1 = load([folder4SM area1 '\' experiment.name]);
        sm1 = sm1.spike_matrix; 
        sm2 = load([folder4SM area2 '\' experiment.name]);
        sm2 = sm2.spike_matrix; 
    
        % load stim prop
        load([folder4stim experiment.name '_StimulationProperties_raw.mat']);
        
        % check stim paradigm and proceed accordingly 
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
        
            % set spikes outside of pulse break periods to zero 
            sm1(:, [1:start1 stop1:start2 stop2:end]) = 0; 
            sm2(:, [1:start1 stop1:start2 stop2:end]) = 0;
            clearvars start1 stop1 start2 stop2
        
        elseif experiment.laserpower < 3 && size(StimulationProperties_raw, 1) == 1
            % all time stamps (in miliseconds after division by 3.2)
            start1 = round(cell2mat(StimulationProperties_raw(1, 1)) / 3.2); 
            stop1 = round(cell2mat(StimulationProperties_raw(1, 2)) / 3.2); 
        
            % trim spike matrix 
            sm1(:, [1:start1 stop1:end]) = 0;
            sm2(:, [1:start1 stop1:end]) = 0;
            clearvars start1 stop1 
        end 
    
        % now calculate STTC (ACC x Str) 
        for lag_idx = 1 : numel(lags)
            lag = lags(lag_idx) / 1000; % convert to seconds
            % reset pair index every lag loop 
            pair = 1; 
            % loop through pairs 
            for unit1 = 1 : size(sm1, 1)
                spike_times_1 = find(sm1(unit1, :)) / 1000; % spike times in seconds 
                N1v = numel(spike_times_1); % number of spikes 
                for unit2 = 1 : size(sm2, 1)
                    spike_times_2 = find(sm2(unit2, :)) / 1000; % spike times in seconds 
                    N2v = numel(spike_times_2);
                    % the calculation step 
                    STTC(pair, lag_idx) = getSTTC(N1v, N2v, lag, [0 max(size(sm1, 2), size(sm2, 1))/1000], spike_times_1, spike_times_2);
                    pair = pair + 1; 
                end 
            end 
        end 
    
        % put in a structure 
        eOPN3sttc.STTC = STTC; 
        eOPN3sttc.lags = lags; 
        eOPN3sttc.note = 'ACC x Str'; 
        
        % save 
        if save_data == 1
            if ~exist([folder2save area1 area2], 'dir')
                mkdir([folder2save area1 area2])
            end 
            save([folder2save area1 area2 '\' experiment.name], 'eOPN3sttc')
        else 
            disp('data not saved!')
        end
        
        % clear variables 
        clearvars sm1 sm2 eOPN3sttc STTC

    end % repeat calc check end 
    toc
end % experiment loop end 

datetime 


%% generate df for R 

% refresh experiment list to include baseline 
experiments = get_experiment_redux;
experiments = experiments(557:end);

% all animals 
mice = unique({experiments.animal_ID});

% initialize 
T = [];

for mouse_idx = 1 : numel(mice)
    mouse = mice{mouse_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse)); 

    % loop through experiments 
    for exp_idx = 1 : numel(exp4mouse)
        experiment = exp4mouse(exp_idx);

        % check condition and handle accordingly 
        % baseline 
        if strcmp(experiment.Exp_type, 'baseline only')
            % load sttc 
            load([folder4baselinesttc area1 area2 '\' experiment.name]); 
            % grab sttc values 
            sttc = Tcoeff.STTC(:, Tcoeff.lags*1000 == lag2use);
            % put in a table 
            temp = table(repmat({mouse}, [numel(sttc), 1]), sttc, repmat({'baseline'}, [numel(sttc), 1]), repmat(experiment.IUEconstruct, [numel(sttc), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
            T = [T; temp]; 
            
            clearvars Tcoeff

        % pulse trains with break 
        elseif strcmp(experiment.Exp_type, 'opto') && experiment.laserpower > 4
            % load sttc 
            load([folder2save area1 area2 '\' experiment.name]); 
            % grab sttc values 
            sttc = eOPN3sttc.STTC(:, eOPN3sttc.lags == lag2use);
            % put in a table 
            temp = table(repmat({mouse}, [numel(sttc), 1]), sttc, repmat({'pulses'}, [numel(sttc), 1]), repmat(experiment.IUEconstruct, [numel(sttc), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
            T = [T; temp]; 

            clearvars eOPN3sttc

        % constant on 
        elseif strcmp(experiment.Exp_type, 'opto') && experiment.laserpower < 3 
            % load sttc 
            load([folder2save area1 area2 '\' experiment.name]); 
            % grab sttc values 
            sttc = eOPN3sttc.STTC(:, eOPN3sttc.lags == lag2use);
            % put in a table 
            temp = table(repmat({mouse}, [numel(sttc), 1]), sttc, repmat({'constant'}, [numel(sttc), 1]), repmat(experiment.IUEconstruct, [numel(sttc), 1]), ...
            'VariableNames', {'mouse','sttc','condition', 'opsin'});
            T = [T; temp]; 

            clearvars eOPN3sttc
        end 
        clearvars sttc temp 
    end % experiment loop end 
end 

% save 
writetable(T, [folder2save 'eOPN3sttc_' area1 area2 '_' num2str(lag2use) '.csv'], 'Delimiter', ',');





