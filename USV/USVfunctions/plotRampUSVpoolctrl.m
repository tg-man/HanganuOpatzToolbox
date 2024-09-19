function [p1, p2] = plotRampUSVpoolctrl(experiments, folder4stim)

% generate a plot for USV with Ramp stim 

Gwindow = gausswin(1001, 4); % gaussian window
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
call_tot = []; 
map4plot = viridis(100);
pre = 1 : 3000; 
during = 3001 : 6000; 
post = 6001 : 9000; 

animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

% calculate one animal at a time 
for animal_idx = 1 : size(animals, 2) 
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal)); 
   
    call_mouse = []; 

    % loop through experiments 
    for exp_idx = 1 : size(experiments4mouse, 2) 
        experiment = experiments4mouse(exp_idx); 
    
        syllables = []; 
       
        % load and process stim properties 
        load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
        ramps = strcmp(cat(1, StimulationProperties_raw(:, 8)), 'ramp') & cell2mat(StimulationProperties_raw(:, 7)) > 0;
        stimstarts = round(cell2mat(StimulationProperties_raw(ramps)) / 3.2); 
        stimstarts = stimstarts(1:30); 
        clear StimulationProperties_raw 

        % load and process USV data 
        load([experiment.USV_path experiment.USV '.mat']); 
        Calls = Calls(Calls.Accept == 1, :);
        % check if the first labeling is 9, the start and last labeling is 8, the end 
        if double(string(Calls.('Type')(1))) == 9 && double(string(Calls.('Type')(end))) == 8 
            syllables(:, 1) = Calls.('Box')(:,1); % extract beginning timestamps
            syllables = round((syllables - syllables(1, 1)) * 1000); % justify recording beginning and convert to ms to fit spike matrix  
            syllables(1, :) = []; % remove the first "call" - artificially added
            callvec(syllables) = 1; 
            callvec(end) = 0; % set the recording end to 0 - artificially added
            % callvec = downsamp_convolve(callvec, Gwindow, 1); % convolve it - but this line doesn't seem to do much... why tho? 
        else 
            disp([experiment.USV ' start or end incorrectly labeled!'])
        end 
    
        % create ramp call mat, one stim at a time
        rampcalls = zeros(size(stimstarts,1), 10000); 
        if exist('callvec', 'var')
            for ramp = 1 : size(stimstarts, 1)
                rampcalls(ramp, :) = callvec(stimstarts(ramp) - 4000 : stimstarts(ramp) + 5999);
            end 
        end 
        call_mouse = [call_mouse; rampcalls]; 
        clear syllables callvec
    end 
    call_tot = cat(3, call_tot, call_mouse); % dimension: ramps x time x animal *** 
end % animal loop end 

call_ds = squeeze(mean(call_tot, 1)); 
call_ds = downsamp_convolve(call_ds', Gwindow, 1); 
call_ds = call_ds'; 
call_ds = squeeze(mean(reshape(call_ds, 100, [], size(call_ds, 2)), 1))'; 
call_ds = zscore(call_ds, [], 2);
figure; 
imagesc(call_ds); colormap(map4plot); % plot
hold on; 
xline(size(call_ds,2)*0.3, 'w:', 'LineWidth', 1)
xline(size(call_ds,2)*0.6, 'w:', 'LineWidth', 1)
xticks([30 60 90]); xticklabels({3 6 9});
xlabel('Time (s)'); ylabel('Mouse')
set(gca, 'TickDir', 'out'); set(gca, 'FontSize', 14); set(gca, 'FontName', 'Arial')
title(['USV to pooled ramp, ctrl'])

figure;
boundedline(linspace(0, 10, size(call_ds, 2)), mean(call_ds), std(call_ds) ./ sqrt(size(call_ds, 1))); 
hold on
xticks([3 6 9])
xline(3, ':k', 'linewidth', 1.5) % reference line for opto
xline(6, ':k', 'linewidth', 1.5) % reference line for opto
ylabel('USV z-score'); xlabel('Time (s)'); xlim([0 10])
title(['USV to pooled ramp, ctrl'])
set(gca, 'TickDir', 'out', 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2)
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end

% sum calls together across ramps and make data frame
call_tot = squeeze(sum(call_tot, 1))'; 
df(:, 1) = sum(call_tot(:, pre), 2); 
df(:, 2) = sum(call_tot(:, during), 2); 
df(:, 3) = sum(call_tot(:, post), 2); 
% plotting total call number during each period 
figure; 
violins = violinplot(df, {'pre', 'during', 'post'}, 'ViolinAlpha', 0.7, 'Width', 0.4, 'EdgeColor', [0 0 0], 'BoxColor', [0 0 0]); 
for idx = 1:size(violins, 2)
    violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0]; 
    violins(idx).ScatterPlot.MarkerFaceAlpha = 1; 
end
set(gca, 'FontSize', 14, 'FontName', 'Arial', 'LineWidth', 2, 'TickDir', 'out'); 
title(['USV to pooled ramp, ctrl'])

% stats test 
[p1, h1] = signrank(df(:, 1), df(:, 2));
[p2, h2] = signrank(df(:, 1), df(:, 3));

end % function end 