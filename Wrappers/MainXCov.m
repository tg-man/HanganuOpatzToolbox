%% cross covariance of spike trains 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4xcov = 'Q:\Personal\Tony\Analysis\Results_Xcov\'; 
folder4sm = 'Q:\Personal\Tony\Analysis\Results_SpikeMatrix\'; 
folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 

area0 = 'ACC'; 
layer0 = 'sup'; 
area1 = 'Str'; 

% Xcov params 
bin_size = 1; 
bin_size_corr = 20; 
maxLag = 512; 

repeatCalc = 0;
save_data = 1;

for exp_idx = 1 : size(experiments, 2)
    experiment = experiments(exp_idx); 

    % first check repeatCalc and whether file already exist or not 
    if repeatCalc == 0 && exist([folder4xcov area0 layer0 area1 '\' experiment.name '.mat'], 'file')
        disp(['computer Xcov exp ' num2str(exp_idx) ' / ' num2str(numel(experiments)) ' already computed']); 
    else 
        if (strcmp(area1, 'Str') && experiment.target2 == 1) || (strcmp(area1, 'TH') && experiment.target3 == 1)
            disp(['computer Xcov exp ' num2str(exp_idx) ' / ' num2str(numel(experiments))]); 
    
            % select which cells to use from spike_matrix0 from SUAinfo.channel
            load([folder4suainfo area0 '\' experiment.animal_ID])
            for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
                if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                    if strcmp(layer0, 'sup')
                        cells2keep = [SUAinfo{1, i}.channel] < 5; % select only superficial cells, the first 4 channels 
                    elseif strcmp(layer0, 'deep')
                        cells2keep = [SUAinfo{1, i}.channel] > 12; % select only deep cells, from the last 4 channels 
                    end 
                end 
            end 
    
            % load SM0 and filter out cells 
            spike_matrix0 = load([folder4sm area0 '\' experiment.name]).spike_matrix;
            spike_matrix0 = spike_matrix0(cells2keep, :); % cell selection here 
        
            % load SM1 
            spike_matrix1 = load([folder4sm area1 '\' experiment.name]).spike_matrix;
        
            % actual computation here 
            norm_xcov = getXcov(spike_matrix0, spike_matrix1, bin_size, bin_size_corr, maxLag); 
        
            % generic save data commands 
            if save_data == 1 
                if ~exist([folder4xcov area0 layer0 area1] , 'dir')
                    mkdir([folder4xcov area0 layer0 area1]); 
                end 
                save([folder4xcov area0 layer0 area1 '\' experiment.name], "norm_xcov")
            end 
        end 
    end 
 
end 




