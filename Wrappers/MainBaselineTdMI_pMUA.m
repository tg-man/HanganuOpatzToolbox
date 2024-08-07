%% 

clear
experiments = get_experiment_redux;
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 
repeatCalc = 0;
save_data = 1;
cores = 6; 

folder4sm = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder2save = 'Q:\Personal\Tony\Analysis\Results_TdMI\Baseline_conv\'; 
area1 = 'ACC'; 
area2 = 'Str'; 

% plotting or not 
plotting = 1; 

% params for function
bin = 5; 
shift = 500; 

% convolution parameters
Gwindow = gausswin(1001, 10); % gaussian window of 1000ms with stdev of 100ms
% Gwindow = Gwindow / sum(Gwindow); % normalize the gaussian kernel

% notes 
notes = 'pseudoMUA, convolved and rounded'; 

%% computation 

% initialize  
tdmi2plot = NaN(numel(experiments), 2*shift/bin + 1); 

parfor (exp_idx = 1 : numel(experiments), cores) 
    experiment = experiments(exp_idx); 
    
    tic
    % check for repeat calc
    if repeatCalc == 0 && exist([folder2save area1 area2 '\' experiment.name '.mat'], 'file')
        disp(['computed values loaded for ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
        TdMI = load([folder2save area1 area2 '\' experiment.name '.mat']).TdMI; 
        tdmi2plot(exp_idx, :) = TdMI.tdmi; 
    else 
        % check targeting 
        if (strcmp(experiment.Area2, area2) && experiment.target2 == 1) || (strcmp(experiment.Area3, area2) && experiment.target3 == 1)
            sm1 = sum(full(load([folder4sm area1 '\' experiment.name]).spike_matrix), 1); 
            sm2 = sum(full(load([folder4sm area2 '\' experiment.name]).spike_matrix), 1); 

            % code for convolution 
            sm1 = round(conv(sm1, Gwindow, 'same')); 
            sm2 = round(conv(sm2, Gwindow, 'same')); 

            % computer everyting and put in a structure 
            disp(['computing TdMI for ' num2str(exp_idx) ' / ' num2str(numel(experiments))])
            tdmi = getTdMI(experiment, sm1, sm2, bin, shift, area1, area2, save_data, folder2save, notes); 
            tdmi2plot(exp_idx, :) = tdmi; 
        end 
    end
    toc 
end 

% plotting 
if plotting == 1
    b = -shift: bin : shift; 
    % total 
    figure; boundedline(b, nanmedian(tdmi2plot, 1), nanstd(tdmi2plot, 1) / sqrt(size(tdmi2plot, 1))); 
    lines = findobj(gcf,'Type','Line');
    for i = 1:numel(lines)
        lines(i).LineWidth = 2;
    end
    xline(0, ':k');
    xlabel('Time delay (ms)'); 
    ylabel('MI (bits)');
    title('L: Str leading        R: ACC leading')

    % single ones 
    figure; hold on; 
    xline(0, ':k');
    for i = 1: size(tdmi2plot, 1)
        plot(b, tdmi2plot(i, :)); 
    end 
end 
