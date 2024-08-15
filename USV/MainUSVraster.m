
clear
experiments = get_experiment_redux;
experiments = experiments([256:301 324:399]); % [300 301 324:380]
save_data = 1; 

BrainArea = 'ACC'; % {'ACC', 'Str', 'TH'}
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

minInterSyInt = 5000; 
minSong = 8; 

map4plot = viridis(100);
Gwindow = gausswin(1000, 2); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 

    % get a list of all cells 
    cells = [];
    for exp_idx = 1 : size(experiments4mouse, 2) 
        experiment = experiments4mouse(exp_idx); 
        load([folder4SM BrainArea '\' experiment.name]); 
        cells = union(cells, clusters); 
    end 

    usvmat_animal = []; 
    % make polled usv spike tensor 
    for exp_idx = 1 : size(experiments4mouse, 2) 
        experiment = experiments4mouse(exp_idx); 
        
        % load spike matrix 
        load([folder4SM BrainArea '\' experiment.name]); 

        syllables = []; 
        % load USV file 
        load([experiment.USV_path experiment.USV '.mat'])
        Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
        syllables(:, 1) = Calls.('Box')(:,1); % extract beginning timestamps
        syllables(:, 2) = Calls.('Box')(:,1) + Calls.('Box')(:, 3);
        syllables = round((syllables - syllables(1, 1)) * 1000); % justify recording beginning and convert to ms to fit spike matrix 
        syllables(1, :) = []; % remove the first "call" - artificially added
        
        if size(syllables, 1) > 1
            % merge calls if they are close enough together 
            songs = []; 
            song = syllables(1, :); 
            for sy_idx = 2 : size(syllables, 1) 
                if syllables(sy_idx, 1) - song(2) < minInterSyInt
                    song(2) = syllables(sy_idx, 2);
                else 
                    songs = [songs; song]; 
                    song = syllables(sy_idx, :); 
                end 
            end 
            songs = [songs; song]; 

            % in case the first one starts too early, drop 
            if songs(1) < minInterSyInt
                songs(1,:) = []; 
            end 
            % in case the last call is too late, drop
            while songs(end,1) + minInterSyInt > size(spike_matrix,2)
                songs(end,:) = [];
            end 


            % check if there're enough songs 
            if size(songs, 1) >= 1 
                % initialize a plotting matrix, cells X (double song inter) X trials 
                usvmat = zeros(numel(clusters), 2*minInterSyInt, size(songs, 1)); 
                for song_idx = 1 : size(songs, 1)
                    usvmat(:, :, song_idx) = full(spike_matrix(:, (songs(song_idx) - minInterSyInt + 1):(songs(song_idx) + minInterSyInt))); 
                end 
                usvmat_temp(logical(sum(cells == clusters, 2)), :, :) = usvmat;
                usvmat_temp(~logical(sum(cells == clusters, 2)), :, :) = 0; 
                usvmat_animal = cat(3, usvmat_animal, usvmat_temp); 
                clear usvmat_temp
            end 
        end        
    end 

    % check if the animal vocalized enough and make some calc
    if size(usvmat_animal, 3) > minSong
        song_num = size(usvmat_animal, 3); 
        % average across songs, covolution, and zscore 
        usvmat_animal_mean = mean(usvmat_animal, 3);
        usvmat_animal_mean = downsamp_convolve(usvmat_animal_mean, Gwindow, 1); 
        z2plot = zscore(usvmat_animal_mean, [], 2); 
        idx_sorted = sort_peak_time(z2plot, 500); % sort 
        
        % sorted raster justified to song onset 
        figure; 
        subplot(211); 
        imagesc((-minInterSyInt + 1:minInterSyInt)/1000, 1:size(z2plot, 1), flipud(z2plot(idx_sorted, :))); colormap(map4plot) % plot
        xline(0, ':w','LineWidth', 1.5); ylabel('Cells'); 
        set(gca, 'FontSize', 14, 'FontName', 'Arial')
        xticks([-4 -2 0 2 4]); %xlabel('Time (s)');
        title([experiment.animal_ID ' ' BrainArea], 'FontWeight','normal') 
        subplot(212); 
        boundedline((-minInterSyInt + 1 : minInterSyInt)/1000, mean(z2plot), std(z2plot) ./ sqrt(numel(cells)))
        lines = findobj(gcf,'Type','Line');
        for i = 1:numel(lines)
          lines(i).LineWidth = 1.5;
        end
        xline(0, ':k','LineWidth', 1); 
        xticks([-4 -2 0 2 4]); xlabel('Time (s)'); ylabel('z-score fr'); 
        set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1)
    
        presong_score = []; 
        for cell_idx = 1 : size(z2plot, 1) 
            if ~ mean(z2plot(cell_idx, :) == zeros([2*minInterSyInt,1])) == 0 % inactive cell 
                presong_score(cell_idx) = NaN; 
            else 
                presong_score(cell_idx) = mean(find(z2plot(cell_idx, :) == max(z2plot(cell_idx, :))) < minInterSyInt); 
            end 
        end 

        report(animal_idx).animal = animal;
        report(animal_idx).age = experiment.age; 
        report(animal_idx).area = BrainArea; 
        report(animal_idx).clusters = cells; 
        report(animal_idx).song_num = song_num; 
        report(animal_idx).presong_score = presong_score; 
        report(animal_idx).presong_prop =  sum(rmmissing(presong_score) == 1) / numel(presong_score);
    else 
        report(animal_idx).animal = animal; 
        report(animal_idx).age = experiment.age; 
        report(animal_idx).area = BrainArea; 
        report(animal_idx).clusters = cells; 
        report(animal_idx).song_num = size(usvmat_animal, 3); 
        report(animal_idx).presong_score = NaN;
        report(animal_idx).presong_prop = NaN; 
    end 
end

% figure; violinplot([report.presong_prop]); 
% ylabel('Proportion of pre-song units'); yline(0.5, ':k');
% set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
