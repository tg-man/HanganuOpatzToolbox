
clear
experiments = get_experiment_redux;
experiments = experiments(256:281);  
save_data = 1;
repeatCalc = 1; 

BrainArea = 'ACC'; % {'ACC', 'Str', 'TH'}
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 

precall_cut = 0.6;

map4plot = viridis(100);
Gwindow = gausswin(21, 10); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

usvmat_tot = []; 

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 

    % get a list of all cells 
    load([folder4suainfo BrainArea '\' animal]); 
    cells = [];
    for exp_idx = 1 : size(experiments4mouse, 2) 
        cells = union(cells, [SUAinfo{1, exp_idx}.ClusterID]); 
    end 

    % make pooled matrix for animal
    usvmat_animal = []; 

    for exp_idx = 1 : size(experiments4mouse, 2) 
        experiment = experiments4mouse(exp_idx); 

        load([folder4SM BrainArea '\' experiment.name]); 

        % load USV file 
        load([experiment.USV_path experiment.USV '.mat'])
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
        if size(Calls, 1) >= 3
            timestamps = Calls.('Box')(:,1); % extract beginning timestamps
            timestamps = round((timestamps - timestamps(1, 1)) * 1000); % justify recording beginning and convert to ms to fit spike matrix 
            timestamps(1) = []; % remove the first "call" - artificially added
    
            % initialize a plotting matrix, cells X 500ms X trials 
            usvmat = zeros(size(spike_matrix, 1), 500, size(timestamps, 1)); 
            % make a call matrix 
            for call_idx = 1 : size(timestamps, 1) 
                usvmat(:, :, call_idx) = full(spike_matrix(:, timestamps(call_idx) - 249 : timestamps(call_idx) + 250));
            end 
            % poll the call matrix together for all experiments 
            usvmat_temp(logical(sum(cells == [SUAinfo{1,exp_idx}.ClusterID], 2)), :, :) = usvmat; 
            usvmat_animal = cat(3, usvmat_animal, usvmat_temp); 
            clear usvmat_temp
        end 
    end

    usvmat_tot = [usvmat_tot; mean(usvmat_animal, 3)]; 
end 

usvmat_tot = downsamp_convolve((usvmat_tot), Gwindow, 1); 
usvmat_tot_z = zscore(usvmat_tot); 
idx_sorted = sort_peak_time(usvmat_tot, 5); 
figure; imagesc(-249:250, 1:size(usvmat_tot_z, 1), flipud(usvmat_tot_z(idx_sorted, :))); colormap(map4plot) % plot
xline(0, ':w','LineWidth', 1.5); ylabel('Cells'); 
set(gca, 'FontSize', 14, 'FontName', 'Arial')
figure; 
boundedline(-249:250, mean(usvmat_tot_z), std(usvmat_tot_z) ./ sqrt(size(usvmat_tot, 1)))
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 1.5;
end
xline(0, ':k','LineWidth', 1); xlabel('Time (ms)'); ylabel('z-score fr'); xlim([-249 250])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)


    % sorted raster justified to USV onset 
    usvmat_mean_z = zscore(usvmat_mean, [], 2);
    usvmat_mean_z = downsamp_convolve(usvmat_mean_z, Gwindow, 1); 
    idx_sorted = sort_peak_time(usvmat_mean_z, 5);
    figure; 
    subplot(211); imagesc(-249:250, 1:size(usvmat_mean_z, 1), flipud(usvmat_mean_z(idx_sorted, :))); colormap(map4plot) % plot
    
    title(experiment.animal_ID)
    
    subplot(212); 


    usvmat_tot_conv = []; 
    % convolve single trial matrix 
    for call_idx = 1 : size(usvmat_tot, 3) 
        usvmat_tot_conv(:, :, call_idx) = downsamp_convolve(usvmat_tot(:, :, call_idx), Gwindow, 1); 
        for cell_idx = 1 : numel(cells)
            usvmat_tot_conv(cell_idx, :, call_idx)
        end 
    end 
 
    % find max in each 
    peaks = []; 
    peakcells = [];
    precall = []; 
    postcall = []; 
    for cell_idx = 1 : size(cells, 1) 
        peak_temp = find((usvmat_mean_z(cell_idx, :) == max(usvmat_mean_z(cell_idx, :)))); 
        peaks = [peaks, peak_temp]; 
        peakcells = [peakcells, repmat(cells(cell_idx),[1, numel(peak_temp)])]; 
        precall(cell_idx) = (sum(peak_temp < 250) / numel(peak_temp)) > precall_cut; 
        clear peak_temp
    end 

    fraction(animal_idx) = sum(precall) / (numel(cells) - sum(sum(usvmat_mean_z, 2) == 0)); 

