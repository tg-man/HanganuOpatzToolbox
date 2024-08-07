%% Main USV Raster

clear
experiments = get_experiment_redux;
experiments = experiments([256:281]);  
save_data = 1;
repeatCalc = 1; 

BrainAreas = {'TH'}; % {'ACC', 'Str', 'TH'}
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

map4plot = viridis(100);
Gwindow = gausswin(21, 10); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

for area_idx = 1 : size(BrainAreas, 2) 
    BrainArea = BrainAreas{area_idx}; 

    for exp_idx = 1 : size(experiments, 2) 
        experiment = experiments(exp_idx); 
    
        % load spike matrix 
        load([folder4SM BrainArea '\' experiment.name]); 
    
        % load USV file 
        load([experiment.USV_path experiment.USV '.mat'])
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 

        if size(Calls, 1) > 4
            timestamps = Calls.('Box')(:,1); % extract beginning timestamps
            timestamps = round((timestamps - timestamps(1, 1)) * 1000); % justify recording beginning and convert to ms to fit spike matrix 
        
            % initialize a plotting matrix, cells X 500ms X trials 
            usvmat = NaN(size(spike_matrix, 1), 500, size(timestamps, 1)); 
        
            for call_idx = 2 : size(timestamps, 1) 
                usvmat(:, :, call_idx) = full(spike_matrix(:, timestamps(call_idx) - 249 : timestamps(call_idx) + 250));
            end 
            usvmat(:, :, 1) = []; % remove the first trial as it's the non-existent 
            usvmat = sum(usvmat, 3);
        
            % sorted raster justified to USV onset 
            usvmat_z = zscore(usvmat, [], 2);
            usvmat_z = downsamp_convolve(usvmat_z, Gwindow, 1); 
            idx_sorted = sort_peak_time(usvmat_z, 5);
            figure; imagesc(-249:250, 1:size(usvmat_z, 1), flipud(usvmat_z(idx_sorted, :))); colormap(map4plot) % plot
            xline(0, ':w','LineWidth', 1.5); xlabel('Time (ms)'); ylabel('Cells'); 
            title([experiment.animal_ID ' ' BrainArea ' ' experiment.square]); 
        
    %         % average line profile 
    %         figure; 
    %         boundedline(-249:250, mean(usvmat_z), std(usvmat_z) ./ sqrt(size(usvmat_z, 1)));
    %         lines = findobj(gcf,'Type','Line');
    %         for i = 1:numel(lines)
    %             lines(i).LineWidth = 2;
    %         end
    %         xline(0, ':k','LineWidth', 1.5); xlabel('Time (ms)'); ylabel('zscored FR'); 
    %         title([experiment.animal_ID ' ' BrainArea]); 
        end 
    end 

end 

