% filter experiments 
clear
experiments = get_experiment_redux;
experiments = experiments(557:end);

repeat_calc = 0; 
save_data = 1;

% SDR params
freq_bin = [4 45]; 
ch_acc = 17:32; 
ch_str = 1:16;

% useful paths 
folder4eOPN3power = 'Q:\Personal\Tony\Analysis\Results_eOPN3Power\';
folder2save = 'Q:\Personal\Tony\Analysis\Results_eOPN3sdr\'; 

% all animals 
mice = unique({experiments.animal_ID});

T = []; 

for mouse_idx = 1 : numel(mice)
    mouse = mice{mouse_idx}; 
    load([folder4eOPN3power mouse '.mat'])
    freqs = eOPN3power.freq; 

    % baseline sdr 
    baseline = simpleMI(getSDR(nanmedian(eOPN3power.spectra_baseline(ch_acc, :)), nanmedian(eOPN3power.spectra_baseline(ch_str, :)), freqs, freq_bin)); 
    % pulse 1 sdr 
    pulses1 = simpleMI(getSDR(nanmedian(eOPN3power.spectra_pulses1(ch_acc, :)), nanmedian(eOPN3power.spectra_pulses1(ch_str, :)), freqs, freq_bin)); 
    % pulse 2 sdr 
    pulses2 = simpleMI(getSDR(nanmedian(eOPN3power.spectra_pulses2(ch_acc, :)), nanmedian(eOPN3power.spectra_pulses1(ch_str, :)), freqs, freq_bin)); 
    % contant sdr 
    constant = simpleMI(getSDR(nanmedian(eOPN3power.spectra_constant(ch_acc, :)), nanmedian(eOPN3power.spectra_constant(ch_str, :)), freqs, freq_bin)); 

    % get opsin condition 
    exp4mouse = experiments(strcmp({experiments.animal_ID}, mouse));
    opsin = exp4mouse.IUEconstruct;

    temp = table({mouse}, opsin, baseline, pulses1, pulses2, constant); 
    T = [T; temp]; 
end 

T.pulsesmean = mean([T.pulses1, T.pulses2], 2);

% save df for stats 
writetable(T, [folder2save 'eOPN3sdr_' num2str(freq_bin) '.csv']); 

% plot eOPN3 SDR
figure; 
subplot(121)
violinplot(T(T.opsin == 27, {'baseline', 'pulses1', 'pulses2', 'constant'}));
yline(0, '--')
yline(median(T.baseline(T.opsin == 27)), ':')
ylabel('norm. SDR acc \rightarrow str')
x = ylim; 
subplot(122)
violinplot(T(T.opsin == 27, {'baseline', 'pulsesmean', 'constant'}));
yline(0, '--')
yline(median(T.baseline(T.opsin == 27)), ':')
ylim(x);
sgtitle(['freq bin ' num2str(freq_bin) ' eOPN3']);

% plot control SDR
figure; 
subplot(121)
violinplot(T(isnan(T.opsin), {'baseline', 'pulses1', 'pulses2', 'constant'}));
yline(0, '--')
yline(median(T.baseline(isnan(T.opsin))), ':')
ylabel('norm. SDR acc \rightarrow str')
x = ylim; 
subplot(122)
violinplot(T(isnan(T.opsin), {'baseline', 'pulsesmean', 'constant'}));
yline(0, '--')
yline(median(T.baseline(isnan(T.opsin))), ':')
ylim(x);
sgtitle(['freq bin ' num2str(freq_bin) ' ctrl']);


%% smaller helper 

function MI = simpleMI(x)
if numel(x) == 2 && any(x >= 0)
    MI = (x(1) - x(2)) ./ (x(1) + x(2));
end 
end 
