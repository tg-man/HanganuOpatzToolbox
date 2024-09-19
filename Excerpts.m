
% dynamically naming variables 
N = 10; % number of variables
for k=1:N
    temp_var = strcat( 'variable_',num2str(k) );
    eval(sprintf('%s = %g',temp_var, k*2))
end

% edit line thickness 
lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).LineWidth = 2.8;
end

% text symbols 
ylabel('ERP (\muV)')
title('ACCdeep \rightarrow TH')

% set path to factory setting
restoredefaultpath
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

set(gca, 'FontName', 'Arial', 'FontSize', 16, 'TickDir', 'out', 'LineWidth', 2);
xticklabels({'Ruther', 'NeuroNexus'})
ylabel('Mean firing rate (Hz)') 
ylabel('Mean number of units/channel')
ylabel('Cross-day units (%)'); ylim([0.05 0.98]); yticks([0.1 0.3 0.5 0.7 0.9]) 
yticklabels({'10', '30', '50', '70', '90'})

ylim([0 2.2]) 

lines = findobj(gcf,'Type','Line');
for i = 1:numel(lines)
  lines(i).Color = 'k';
end

% Notes for cellfun
% cellfun(@(inputs) function(inputs), cellarray of inputs)


clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments(197:420);
experiments = experiments(isnan(extractfield(experiments, 'IUEage'))); 
experiments = experiments([experiments.DiI] == 0); 
sup = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));  
deep = experiments(strcmp(extractfield(experiments, 'square'), 'ACCdeep'));  
histogram([sup.age])
