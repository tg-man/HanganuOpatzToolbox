%% USV response to pulse laser 

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
experiments = experiments(extractfield(experiments, 'IUEconstruct') == 13);

folder4stim = 'Q:\Personal\Tony\Analysis\Results_StimProp\';

pulse2check = 50; % in ms 

% get unique animal list 
animals = unique({experiments.animal_ID}); 

totmat = []; 

% loop through animals 
for animal_idx = 1 : numel(animals)
    animal = animals{animal_idx}; 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, animal));

    % initialize a pulse call mat
    pulsecallmat = []; 

    % loop through experiments 
    for exp_idx = 1 : size(exp4mouse, 2)
        experiment = exp4mouse(exp_idx);

        % load stim properties and extract pulse start timestamps 
        load([folder4stim experiment.name, '_StimulationProperties_raw.mat']);
        StimulationProperties_raw = StimulationProperties_raw(ceil(cell2mat(StimulationProperties_raw(:, 5))*1000) == 50, :);
        stimstarts = round(cell2mat(StimulationProperties_raw(:, 1)) ./ 3.2); % in ms, divided by 3.2 because stim prop is in 3.2Hz 
        clear StimulationProperties_raw 

        % load USV file 
        load([experiment.USV_path experiment.USV])
        Calls = Calls(Calls.Accept == 1, :); 
        % remove artificially added labeling 
        if double(string(Calls.Type(1))) == 9 && double(string(Calls.Type(end))) == 8
            Calls(1, :) = []; 
            Calls(end, :) = []; 
        end
        % extract beginning timestamps 
        callstarts = round(Calls.Box(:, 1)*1000); % in ms to align with stim prop
        clearvars Calls audiodata

        % detect pulse by pulse if a call happens 
        for pulse = 1 : numel(stimstarts) 
            % if there's a call around the pulse, set value to 1
            pulsecallmat = [pulsecallmat; double(ismember((stimstarts(pulse)-499):(stimstarts(pulse)+1500), callstarts))]; 
        end % pulse loop end 
    end % experiments loop end 

    % average across trials 
    pulsecallmat = mean(pulsecallmat);

    % put into global variable 
    totmat = [totmat; pulsecallmat];    

end % animal loop end 

% set a gaussian window for convolution 
Gwindow = gausswin(500, 10); % gaussian window 
Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel
figure; plot(Gwindow)

% convolve usv matrix 
tot2plot = downsamp_convolve(totmat, Gwindow, 1); 

% plotting
figure; hold on
boundedline(1:2000, mean(tot2plot), std(tot2plot) ./ sqrt(numel(animals)), 'k'); 
yl = ylim;
fill([500 500 500+pulse2check 500+pulse2check], [0 yl(2) yl(2) 0], [0 0.30 1], 'FaceAlpha', 0.3, 'EdgeColor', 'none')
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2;
end
xlabel('Time (ms)') 
ylabel('Mean # of calls')
set(gca, 'TickDir', 'out', 'FontSize', 16, 'FontName', 'Arial', 'LineWidth', 2); 


