function [RelSpectrum, SpectrumStim, freq] = plotRampPower(experiments, stimArea, plotAreas, folder2load)
% Tony 05.2023
% Adapted from Mattia 10/22
% inputs: 
%   - experiment lists 
%   - stimArea: the area where stimulation was given
%         in my case ACCsup, Str, TH
%   - plotArea: the areas to look at, in {} format 
%   - folder2load: where the output from getRampPower was saved 

% select experiment with the specificed stim area
experiments = experiments(strcmp(extractfield(experiments, 'ramp'), stimArea)); 

% colormap
cmap = cbrewer('div', 'RdBu', 100);

for area_idx = 1: numel(plotAreas)
    plotArea = plotAreas{area_idx}; 
    if strcmp(plotArea, 'ACC')
        CSC = 17:32; 
    elseif strcmp(plotArea, 'Str')
        CSC = 1:16; 
    elseif strcmp(plotArea, 'TH')
        CSC = 33:48; 
    end     
    
    for exp_idx = 1: size(experiments, 2)
        experiment = experiments(exp_idx); 
        bad_ch = [experiment.NoisyCh,experiment.OffCh];
        bad_ch = bad_ch(ismember(bad_ch, CSC));
        
        % load PSD channel by channel and put in matrix(exp X Ch X freq) 
        ch_idx = 1; 
        for channel = CSC
            load([folder2load experiment.name '\' num2str(channel)]); 
            % average across trials
            RelSpectrum(exp_idx, ch_idx, :) = median(getMI(StimPowerRamps.Half2_sup, StimPowerRamps.Pre_sup, 0)); 
            Spectrumpre(exp_idx, ch_idx, :) = median(StimPowerRamps.Pre_sup);
            SpectrumStim(exp_idx, ch_idx, :) = median(StimPowerRamps.Half2_sup);
            
            % take out noisy and off target channels
            if ismember(channel, bad_ch)            
                RelSpectrum(exp_idx, ch_idx, :) = NaN; 
                Spectrumpre(exp_idx, ch_idx, :) = NaN; 
                SpectrumStim(exp_idx, ch_idx, :) = NaN; 
            end 
            ch_idx = ch_idx + 1; 
        end         
        freq = StimPowerRamps.freq; 
    end 

    % average across channels 
    RelSpectrum = squeeze(nanmedian(RelSpectrum, 2));
    Spectrumpre = squeeze(nanmedian(Spectrumpre, 2));
    SpectrumStim = squeeze(nanmedian(SpectrumStim, 2)); 
    
    % plot the relative (MI) spectrum
    figure; hold on
    boundedline(freq, nanmean(RelSpectrum), nanstd(RelSpectrum) ./ sqrt(exp_idx), 'cmap', cmap(90, :))
    plot(get(gca,'xlim'),[0 0],'r','linewidth',3)
    set(gca,'TickDir','out');
    xlabel('Frequency (Hz)');  ylabel('Relative Power');
    set(gca,'FontSize',12); set(gca, 'FontName', 'Arial')
    title(['Relative Power Spectrum - ' plotArea ' to ' stimArea ' stim'])
    xlim([1 49]); ylim([-0.2 0.5]);

    % plot the pre-stim spectrum
    figure; hold on
    boundedline(freq, nanmean(Spectrumpre), nanstd(Spectrumpre) ./ sqrt(exp_idx), 'cmap', cmap(90, :))
    boundedline(freq, nanmean(SpectrumStim), nanstd(SpectrumStim) ./ sqrt(exp_idx), 'cmap', cmap(25, :))
    set(gca,'TickDir','out'); title(['Pre-Stim Power Spectrum - ' plotArea ' to ' stimArea ' stim' ]); 
    xlabel('Frequency (Hz)'); ylabel('Power (\muV^2)');
    set(gca,'FontSize',12); set(gca, 'FontName', 'Arial')
    xlim([1 49]); ylim([0.1 100]); 
    set(gca, 'YScale', 'log')   
    clear RelSpectrum Spectrumpre SpectrumStim
end 
end