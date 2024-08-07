clear
experiments = get_experiment_redux;
experiments = experiments(256:380);  % [300 301 324:380]
save_data = 1; 

BrainArea = 'ACC'; % {'ACC', 'Str', 'TH'}
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 

minInterSyInt = 5000; 
minSong = 8; 
rand_trial_b = 50; 
rand_trial_o = 10; 
rng(5); % seed of random number generator 

map4plot = viridis(100);
Gwindow = gausswin(1001, 5); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

% initialize 
usvmat_tot = []; 

%% 

for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 

    if [experiments4mouse.(['target' num2str(find(strcmp({'ACC','Str','TH'}, BrainArea)))])],(1) == 1; % check targetting 
        % get a list of all cells 
        cells = [];
        for exp_idx = 1 : size(experiments4mouse, 2) 
            experiment = experiments4mouse(exp_idx); 
            load([folder4SM BrainArea '\' experiment.name]); 
            cells = union(cells, clusters); 
        end 
    
        % initialize
        usvmat_animal = []; 
        % make polled usv spike tensor 
        for exp_idx = 1 : size(experiments4mouse, 2) 
            experiment = experiments4mouse(exp_idx); 
            
            % set rand trial param 
            if strcmp(experiment.Exp_type, 'baseline only') 
                rand_trial = rand_trial_b; 
            elseif strcmp(experiment.Exp_type, 'opto') 
                rand_trial = rand_trial_o; 
            end 
    
            % load spike matrix 
            load([folder4SM BrainArea '\' experiment.name]); 
    
            syllables = []; 
            % load USV file 
            load([experiment.USV_path experiment.USV '.mat'])
            Calls = Calls(Calls.Accept == 1, :); % filter out rejected calls 
            % check labeling and extract numbers
            if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8  
                syllables(:, 1) = Calls.('Box')(:,1); % extract beginning timestamps
                syllables(:, 2) = Calls.('Box')(:,1) + Calls.('Box')(:, 3); % extract end timestamps
                syllables = round((syllables - syllables(1, 1)) * 1000); % justify recording beginning and convert to ms to fit to spike matrix 
                syllables(1, :) = []; % remove the first "call" - artificially added start
                syllables(end, :) = []; % remove the last "ca;;" - artificially added end 
            else 
                 disp([experiment.USV ' start or end incorrectly labeled!']); 
            end 

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
    
                % check if there're enough songs 
                if size(songs, 1) >= 1 
                    % vector containing all song period timestamps 
                    songperiod = cellfun(@(start, stop) (start:stop), num2cell(songs(:, 1)), num2cell(songs(:, 2)), 'UniformOutput', false);
                    songperiod = horzcat(songperiod{:});  % join to be one vector
                    % initialize a plotting matrix, cells X (double song inter) X trials 
                    usvmat = zeros(numel(clusters), 2*minInterSyInt, rand_trial); 
                    % filled matrix with randomized time outside of song period
                    ri = 1; 
                    while ri < (rand_trial + 1)
                        randtime = randi(size(spike_matrix, 2) - 2*minInterSyInt, 1); 
                        if ~logical(sum(ismember(randtime : (randtime + 2*minInterSyInt - 1), songperiod)))
                            usvmat(:, :, ri) = full(spike_matrix(:, randtime : (randtime + 2*minInterSyInt - 1))); 
                            ri = ri + 1; 
                        end   
                    end                
                    usvmat_temp(logical(sum(cells == clusters, 2)), :, :) = usvmat;
                    usvmat_temp(~logical(sum(cells == clusters, 2)), :, :) = 0; 
                    usvmat_animal = cat(3, usvmat_animal, usvmat_temp); 
                    clear usvmat_temp
                end 
            end        
        end  
        
        % check if the animal vocalized enough
        if size(usvmat_animal, 3) > minSong
            usvmat_tot = [usvmat_tot; mean(usvmat_animal, 3)]; 
        end 
    end 
end


% average across songs, covolution, and zscore 
usvmat_tot_conv = downsamp_convolve(usvmat_tot, Gwindow, 1); 
z2plot = zscore(usvmat_tot_conv, [], 2); 
idx_sorted = sort_peak_time(z2plot, 500); % sort 

% sorted raster justified to song onset 
figure; 
imagesc((-minInterSyInt + 1:minInterSyInt)/1000, 1:size(z2plot, 1), flipud(z2plot(idx_sorted, :))); colormap(map4plot) % plot
xline(0, ':w','LineWidth', 1.5); ylabel('Cells'); 
set(gca, 'FontSize', 14, 'FontName', 'Arial')
xticks([-4 -2 0 2 4]); xlabel('Time (s)');
xlim([-4.5 4.5])
title([BrainArea], 'FontWeight','normal') 
% line profile 
figure; 
subplot(211); % zscore
boundedline((-minInterSyInt + 1 : minInterSyInt)/1000, mean(z2plot), std(z2plot) ./ sqrt(size(z2plot, 1)));
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 1.5;
end
xlim([-4.5 4.5]); 
xline(0, ':k','LineWidth', 1); 
xticks([-4 -2 0 2 4]); xlabel('Time (s)'); ylabel('z-score fr'); 
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1); 
title([BrainArea])
subplot(212); % actual fr 
boundedline((-minInterSyInt + 1 : minInterSyInt)/1000, mean(usvmat_tot_conv), std(usvmat_tot_conv) ./ sqrt(size(usvmat_tot_conv, 1)));
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 1.5;
end
xline(0, ':k','LineWidth', 1); 
xticks([-4 -2 0 2 4]); xlabel('Time (s)'); ylabel('fr (Hz)'); 
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 1); 
xlim([-4.5 4.5]); 
% set(gca, 'YScale', 'log')