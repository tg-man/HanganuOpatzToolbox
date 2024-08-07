%% Xcov plotting script 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 
folder4xcov = 'Q:\Personal\Tony\Analysis\Results_Xcov\'; 

area0 = 'ACC';
layer0 = 'sup'; 
area1 = 'Str'; 

age = []; 
xcov_tot = []; 

% call colormap 
YlGnBu = cbrewer('seq', 'YlGnBu', 100);

for exp_idx = 1 : numel(experiments) 
    experiment = experiments(exp_idx); 

    if (strcmp(area1, 'Str') && experiment.target2 == 1) || (strcmp(area1, 'TH') && experiment.target3 == 1)
       
        load([folder4suainfo area0 '\' experiment.animal_ID])
        for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
            if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                if strcmp(layer0, 'sup')
                cells2keep = [SUAinfo{1, i}.channel] < 9; % select only superficial cells, the first 8 channels 
                elseif strcmp(layer0, 'deep')
                cells2keep = [SUAinfo{1, i}.channel] > 8; % select only deep cells, from the last 8 channels 
                end 
            end     
        end 
    
        load([folder4suainfo area1 '\' experiment.animal_ID])
        for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
            if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                clusters1 = ~isnan([SUAinfo{1, i}.channel]); 
            end 
        end 
    
        cellfilter = []; 
        for unit0 = 1 : numel(cells2keep)
            for unit1 = 1 : numel(clusters1)
                cellfilter = [cellfilter; cells2keep(unit0) * clusters1(unit1)];
            end 
        end 

        load([folder4xcov area0 area1 filesep experiment.name])
        norm_xcov = norm_xcov(logical(cellfilter), :); 

        xcov_tot = [xcov_tot; norm_xcov]; 
        age = [age; repmat(experiment.age, [size(norm_xcov, 1), 1])];

    end 
end 

uniqueage = (unique(age)); 

figure; 
for age_idx = 1 : numel(uniqueage)
    plot([-512:512], nanmedian(xcov_tot(age == uniqueage(age_idx), :)), 'LineWidth', 2.5, 'Color', YlGnBu(round(100/8*age_idx),:)); hold on; 
    
    % high light the tip 
    vec = nanmedian(xcov_tot(age == uniqueage(age_idx), :));
    y = max(vec); 
    x = find(vec == y) - 513; 
    plot(x,y,'o','MarkerSize',10, 'Color', YlGnBu(round(100/8*age_idx),:));

end 
box off; 
xlim([-50 50]); xline(0, ':k', 'LineWidth', 2); ylim([-0.5 16])
ylabel('X cov'); xlabel('Time (ms)');
set(gca, 'FontName', 'Arial', 'FontSize', 16, 'TickDir', 'out', 'LineWidth', 2);
title([area0 layer0 area1], 'FontName','Arial'); 



% load([folder4suainfo area0 '\' experiment.animal_ID])
% for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
%     if strcmp(SUAinfo{1, i}(1).file, experiment.name)
%         if strcmp(layer0, 'sup')
%             cells2keep = [SUAinfo{1, i}.channel] < 9; % select only superficial cells, the first 8 channels 
%         elseif strcmp(layer0, 'deep')
%             cells2keep = [SUAinfo{1, i}.channel] > 8; % select only deep cells, from the last 8 channels 
%         end 
%     end 
% end 

