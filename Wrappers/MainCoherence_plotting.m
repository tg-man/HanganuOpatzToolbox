%% Plot Coherence stuff 

clear; 
experiments = get_experiment_redux; % load experiments and generic stuff
experiments = experiments([45:63]); %what experiments to keep 
YlGnBu = cbrewer('seq', 'YlGnBu', 100); % call colormap 
folder4Coh = 'Q:\Personal\Tony\Analysis\Results_3Probe_Coh_coactive\'; 

for exp_idx = 1 : size(experiments, 2)
    
    % select experiment
    experiment = experiments(exp_idx);
    % set age
    age(exp_idx) = experiment.age; 
    
    % load coherence
    % 1 - PFC and Str
    load(strcat(folder4Coh, experiment.animal_ID, '_PFC_Str'));
    coh1(exp_idx, :) = CoherenceStuff.Coherency; 
    coh1ref(exp_idx, :) = CoherenceStuff.CohyShuff; 
    clear CoherenceStuff 
    
    % 2 - Str and TH
    load(strcat(folder4Coh, experiment.animal_ID, '_Str_TH'));
    coh2(exp_idx, :) = CoherenceStuff.Coherency; 
    coh2ref(exp_idx, :) = CoherenceStuff.CohyShuff; 
    clear CoherenceStuff
    
    % 2 - TH and PFC
    load(strcat(folder4Coh, experiment.animal_ID, '_PFC_TH'));
    coh3(exp_idx, :) = CoherenceStuff.Coherency; 
    coh3ref(exp_idx, :) = CoherenceStuff.CohyShuff; 
    if exp_idx == size(experiments, 2) 
        freqs2plot = CoherenceStuff.freqs; 
        age(exp_idx) = experiment.age; 
    end 
    clear CoherenceStuff
end
age = age'; 

%calculate the boundedline values 
n=1; 
for idx = 5:12 
    if ismember (idx, age)
    coh1plot(n,:) = nanmedian(coh1(age==idx,:), 1); 
    shading1(n,:) = nanstd(coh1(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    coh2plot(n,:) = nanmedian(coh2(age==idx,:), 1); 
    shading2(n,:) = nanstd(coh2(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    coh3plot(n,:) = nanmedian(coh3(age==idx,:), 1); 
    shading3(n,:) = nanstd(coh3(age==idx,:), [], 1)./ sqrt(nnz(age==idx)); 
    n = n+1;
    end 
end 

% actually plotting
figure; hold on; 
for idx = 1:size(coh1plot,1)
%     boundedline(freqs2plot, coh1plot(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));
    plot(freqs2plot, coh1plot(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
end 
xlim([2 45]); ylabel('Imag. Coh. (A.U.)'); xlabel('Frequency (Hz)'); ylim([0 0.5]); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh1ref, 1), nanstd(coh1ref, [], 1) ./ sqrt(size(age,1)), ':k'); 
title('Coherence: PFC-Str', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(coh1plot,1)
%     boundedline(freqs2plot, coh1plot(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));
    plot(freqs2plot, coh2plot(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
end 
xlim([2 45]); ylabel('Imag. Coh. (A.U.)'); xlabel('Frequency (Hz)'); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh2ref, 1), nanstd(coh2ref, [], 1) ./ sqrt(size(age,1)), ':k'); 
title('Coherence: Str-TH', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial');

figure; hold on; 
for idx = 1:size(coh1plot,1)
%     boundedline(freqs2plot, coh1plot(idx,:), shading1(idx,:), 'cmap', YlGnBu(round(100/8*idx),:));
    plot(freqs2plot, coh3plot(idx,:), 'Color',  YlGnBu(round(100/8*idx),:)); 
end 
xlim([2 45]); ylabel('Imag. Coh. (A.U.)'); xlabel('Frequency (Hz)'); set(gca, 'FontSize', 16)
boundedline(freqs2plot, nanmedian(coh3ref, 1), nanstd(coh3ref, [], 1) ./ sqrt(size(age,1)), ':k'); 
title('Coherence: TH-PFC', 'FontSize', 18, 'FontWeight', 'bold', 'FontName', 'Arial');
