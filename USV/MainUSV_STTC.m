%% Main USV STTC 

clear
experiments = get_experiment_redux;
experiments = experiments(421:448);  % 256:380 [300 301 324:399] [256:301 303 306 309 312 315 318 321 324:420]
% experiments = experiments([experiments.IUEconstruct] == 13);

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

minInterSyInt = 5000; % threshold to merge USV calls together, in ms
repeat_calc = 0;
lags = [5, 10, 20, 50, 100, 500, 1000]; 
folder4SM = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_USVSTTC\'; 

% calculate STTC, one animal at a time 
for animal_idx = 1 : size(animals, 2) 
    tic
    % get animal number and all experiments for this animal 
    animal = animals{animal_idx}; 
    experiments4mouse = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal));

    if experiments4mouse(1).target2 == 1 % check targeting before going in 
        disp(['STTCing 1 X 2, animal ' num2str(animal_idx) ' / ' num2str(size(animals, 2))])   
        USVSTTC = getUSVSTTC(experiments4mouse, 1, 2, minInterSyInt, lags, repeat_calc, folder4SM, folder2save); 
    end 
    if experiments4mouse(1).target3 == 1 % check targeting before going in 
        disp(['STTCing 1 X 3, animal ' num2str(animal_idx) ' / ' num2str(size(animals, 2))]) 
        USVSTTC = getUSVSTTC(experiments4mouse, 1, 3, minInterSyInt, lags, repeat_calc, folder4SM, folder2save); 
    end 
    toc
end 

%% Plotting script 

clear
experiments = get_experiment_redux;
experiments = experiments([256:301 303 306 309 312 315 318 321 324:420]);  % 256:380 [300 301 324:399]
% experiments = experiments([experiments.IUEconstruct] == 13);

% get unique animal numbers 
animals = extractfield(experiments, 'animal_ID');
animals = animals(~cellfun('isempty', animals));
animals = unique(cellfun(@num2str, animals, 'un', 0));

folder2save = 'Q:\Personal\Tony\Analysis\Results_USVSTTC\'; 

accstr_b = []; 
accstr_prep = []; 
accstr_call = []; 
accth_b = []; 
accth_prep = []; 
accth_call = []; 

for animal_idx = 1 : length(animals) 
    animal = animals{animal_idx}; 
    experiment = experiments(strcmp(extractfield(experiments, 'animal_ID'), animal));
    experiment = experiment(1);
    % ACC x Str 
    if experiment.target2 == 1 
        load([folder2save 'ACCStr\' animal])
        accstr_b = [accstr_b; USVSTTC.baseline]; 
        accstr_prep = [accstr_prep; USVSTTC.prep]; 
        accstr_call = [accstr_call; USVSTTC.during]; 
        clear USVSTTC
    end 
    % ACC x TH 
    if experiment.target3 == 1 
        load([folder2save 'ACCTH\' animal]) 
        accth_b = [accth_b; USVSTTC.baseline]; 
        accth_prep = [accth_prep; USVSTTC.prep]; 
        accth_call = [accth_call; USVSTTC.during]; 
        lags = USVSTTC.lags; 
        clear USVSTTC
    end 
end 

for lag_idx = 2 : length(lags) 
    % ACC x Str 
    % shift values to positive 
    shift = abs(min([accstr_b(:, lag_idx); accstr_prep(:, lag_idx); accstr_call(:, lag_idx)])) + 0.0001; 
    vec2plot1 = log10([accstr_b(:, lag_idx), accstr_prep(:, lag_idx), accstr_call(:, lag_idx)] + shift); % log10 not log!!!!! 
    figure; hold on; 
    violins = violinplot(vec2plot1); 
    ylabel('log of shifted STTC'); xticklabels({'baseline', 'prep', 'calling'});
    set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
%     set(gca, 'YScale', 'log');
    title(['ACC-Str ' num2str(lags(lag_idx)) 'ms lag']);
%     ylim([0 max([accstr_b(:, lag_idx); accstr_prep(:, lag_idx); accstr_call(:, lag_idx)] + 2*shift)]); 
    % simple stats 
    comp_accstr(lag_idx) = nanmedian(accstr_b(:, lag_idx)) < nanmedian(accstr_prep(:, lag_idx)); 
    p_accstr(lag_idx) = signrank(accstr_b(:, lag_idx), accstr_prep(:, lag_idx)); 

    % ACC x TH
    % shift values to positive 
    shift = abs(min([accth_b(:, lag_idx); accth_prep(:, lag_idx); accth_call(:, lag_idx)])) + 0.0001; 
    vec2plot2 = log10([accth_b(:, lag_idx), accth_prep(:, lag_idx), accth_call(:, lag_idx)] + shift); 
    figure; hold on; 
    violins = violinplot(vec2plot2); 
    ylabel('log of shifted STTC'); xticklabels({'baseline', 'prep', 'calling'});
    set(gca, 'FontSize', 14, 'Fontname', 'Arial', 'TickDir', 'out', 'LineWidth', 2); 
%     set(gca, 'YScale', 'log');
    title(['ACC-TH ' num2str(lags(lag_idx)) 'ms lag']);
%     ylim([0 max([accth_b(:, lag_idx); accth_prep(:, lag_idx); accth_call(:, lag_idx)] + 2*shift)]); 
    % simple stats 
    comp_accth(lag_idx) = nanmedian(accth_b(:, lag_idx)) < nanmedian(accth_prep(:, lag_idx)); 
    p_accth(lag_idx) = signrank(accth_b(:, lag_idx), accth_prep(:, lag_idx)); 

end 

% 
% x = accstr_b(:, 3); 
% y = accstr_prep(:, 3); 
% 
% 
% 
% % Generate random example data
% x = randn(1000, 1);  % Random x data (e.g., normally distributed)
% y = randn(1000, 1);  % Random y data (e.g., normally distributed)
% 
% % Create grid points over which to evaluate the density
% gridx = linspace(min(x), max(x), 100);  % Grid for x-axis
% gridy = linspace(min(y), max(y), 100);  % Grid for y-axis
% [XX, YY] = meshgrid(gridx, gridy);      % 2D grid for evaluation
% 
% % Perform 2D kernel density estimation
% data = [x, y];  % Combine x and y into a two-column matrix
% density = ksdensity(data, [XX(:), YY(:)]);  % Compute density on grid points
% 
% % Reshape the density output to fit the grid size
% density_reshaped = reshape(density, size(XX));
% 
% % Plot the 2D Kernel Density Estimate
% figure;
% contourf(gridx, gridy, density_reshaped);  % Filled contour plot
% colorbar;  % Show color bar to indicate density levels
% xlabel('X-axis');
% ylabel('Y-axis');
% title('2D Kernel Density Plot');
% 
% refline
% 
% 
% 
% STTC_baseline = a1*x + b1; % baseline 
% STTC_prep = a2*x + b2; 
% 
% log10STTC ~ USVphase + (1 | mouse) % in R 




