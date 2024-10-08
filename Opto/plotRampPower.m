function [Spectrumpre, SpectrumStim, freq] = plotRampPower(experiments, stimArea, plotAreas, folder2load)
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
        
        % check targeting
        if experiment.(['target' num2str(area_idx)]) == 1
        
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
        
        else
            RelSpectrum(exp_idx, 1:16, :) = NaN; 
            Spectrumpre(exp_idx, 1:16, :) = NaN; 
            SpectrumStim(exp_idx, 1:16, :) = NaN;            
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
    lines = findobj(gcf,'Type','Line');
    for i = 1:numel(lines) 
        lines(i).LineWidth = 2;
    end
    yline(0, ':k', 'LineWidth', 1.5)
    xlabel('Frequency (Hz)');  ylabel('Relative Power');
    set(gca,'FontSize', 16, 'FontName', 'Arial', 'TickDir','out', 'LineWidth', 2); 
    title(['Relative Power Spectrum - ' plotArea ' to ' stimArea ' stim'])
    xlim([1 49]); ylim([-0.15 0.2]);

    % plot the pre-stim spectrum
    figure; hold on
    boundedline(freq, nanmean(Spectrumpre), nanstd(Spectrumpre) ./ sqrt(exp_idx), 'cmap', cmap(90, :))
    boundedline(freq, nanmean(SpectrumStim), nanstd(SpectrumStim) ./ sqrt(exp_idx), 'cmap', cmap(25, :))
    lines = findobj(gcf,'Type','Line');
    for i = 1:numel(lines) 
        lines(i).LineWidth = 2;
    end
    title(['Pre-Stim Power Spectrum - ' plotArea ' to ' stimArea ' stim' ]); 
    xlabel('Frequency (Hz)'); ylabel('Power (\muV^2)');
    set(gca,'FontSize', 16, 'FontName', 'Arial', 'TickDir','out', 'LineWidth', 2); 
    xlim([1 49]); ylim([0.1 100]); 
    set(gca, 'YScale', 'log'); 
    legend('', 'pre', '', 'stim'); legend boxoff; 
    
    % add some code here and put the output in different structure fields 
    
    clear RelSpectrum Spectrumpre SpectrumStim
end 
end