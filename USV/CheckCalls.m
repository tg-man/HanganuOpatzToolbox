%% this
% this script is written for deprecated chemoGenetic Experiments 
% but still has useful functions to take 

clear 
folder4stats = 'Q:\Personal\Tony\Analysis\Results_USV\Stats\';
folder4output = 'Q:\Personal\Tony\Analysis\Results_USV\'; 
folder4pics = 'Q:\Personal\Tony\Analysis\Results_PharmUSVcalls\';
load('Q:\Personal\Tony\Analysis\callclusters3.txt')
L1 = readtable('Q:\Personal\Tony\Analysis\PharmUSV.xlsx');
allcalls = readtable('Q:\Personal\Tony\Analysis\PharmUSV_calltot_4.csv', 'Delimiter', ',');
allcalls.cluster = callclusters3; 

L1 = L1(L1.exp_L == 1 & L1.exp_R == 1,:);
L1.exp_L = []; 
L1.exp_R = []; 

% Parameters
windowLength = 1000;             % Window length in samples (4 ms)
window = hamming(windowLength);  % Hamming window
noverlap = windowLength / 2;     % 50% overlap
nfft = 1024;                     % Number of FFT points

for i = 1 : height(L1)
    % load sorting output file
    load([folder4output L1.file{i}]);
    % filter only accepted calls 
    Calls = Calls(Calls.Accept, :); 
    % load the audio file 
    audio = audioread(audiodata.Filename); 
    Calls.Box(:, 2) = Calls.Box(:, 2)*1000; % from kHz to Hz 
    Calls.Box(:, 4) = Calls.Box(:, 4)*1000; % from kHz to Hz 

    % filter allcalls table based on filename 
    filename = strsplit(audiodata.Filename, '\'); 
    filename = filename{end}; 
    filename = filename(1 : end - 4); 
    animalcalls = allcalls(contains(allcalls.File, filename), :); 

    % Compute and display the spectrogram
    [S, F, T, P] = spectrogram(audio, window, noverlap, nfft, audiodata.SampleRate, 'yaxis');
    figure;
    imagesc(T, F, 10 * log10(P)); % Manual plot of PSD in dB/Hz
    axis xy;
    xlabel('Time (s)');
    ylabel('Frequency (Hz)');
    title('Manual Spectrogram (dB/Hz)');
    colormap inferno;
    colorbar;
    clim([-130 -50]); 
    set(gca, 'TickDir', 'out')

    % loop through each calls to save a fig of just the one call
    for j = 1 : size(Calls, 1)

        % find the index in the time vector for this call
        idx_xmin = find(T > (Calls.Box(j,1) - 0.08), 1); 
        idx_xmax = find(T > (Calls.Box(j,1) + 0.17), 1); 

        % create the figure
        figure;
        imagesc(T(idx_xmin:idx_xmax), F, 10*log10(P(:, idx_xmin:idx_xmax)));
        axis xy;
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title([filename ', call #' num2str(j) ', cluster #' num2str(animalcalls.cluster(j))]);
        colormap inferno;
        colorbar;
        clim([-130 -50]); 
        set(gca, 'TickDir', 'out')
        % add a box
        rectangle('Position', Calls.Box(j, :),'EdgeColor' , 'g'); 
        % name the call snippets: file_num_cluster, and save
        saveas(gcf, [folder4pics filename '_' num2str(j) '_' num2str(animalcalls.cluster(j)) '.fig']);
        % close figure to release memory
        close(gcf); 
    end 
    % close all figures here 
    close all; 
end 


% %% make percentage of clusters on an animal level 
% % clusters labels are based on pooled t-sne and kmeans run 
% 
% clear 
% load('Q:\Personal\Tony\Analysis\callclusters3.txt')
% L1 = readtable('Q:\Personal\Tony\Analysis\PharmUSV.xlsx');
% allcalls = readtable('Q:\Personal\Tony\Analysis\PharmUSV_calltot_4.csv', 'Delimiter', ',');
% allcalls.cluster = callclusters3; 
% 
% L1 = L1(L1.exp_L == 1 & L1.exp_R == 1,:);
% L1.exp_L = []; 
% L1.exp_R = []; 
% 
% animals = unique(L1.mouse); 
% 
% % Create an empty table with no rows
% varNames = {'mouse', 's0', 's1', 's2', 'c0', 'c1', 'c2'};
% varTypes = {'string', 'double', 'double', 'double', 'double', 'double', 'double'};
% df = table('Size', [length(animals), length(varNames)], 'VariableTypes', varTypes, 'VariableNames', varNames);
% 
% for i = 1 : length(animals)
%     animal = animals{i};
%     calls4animal = allcalls(strcmp(allcalls.mouse, animal), :);
% 
%     % calculate the numbers and fill in table
%     df.mouse(i) = animal; 
%     df.s0(i) = sum(calls4animal.C21 == 0 & calls4animal.cluster == 0) / sum(calls4animal.C21 == 0); 
%     df.s1(i) = sum(calls4animal.C21 == 0 & calls4animal.cluster == 1) / sum(calls4animal.C21 == 0); 
%     df.s2(i) = sum(calls4animal.C21 == 0 & calls4animal.cluster == 2) / sum(calls4animal.C21 == 0); 
%     df.c0(i) = sum(calls4animal.C21 == 1 & calls4animal.cluster == 0) / sum(calls4animal.C21 == 1);
%     df.c1(i) = sum(calls4animal.C21 == 1 & calls4animal.cluster == 1) / sum(calls4animal.C21 == 1);
%     df.c2(i) = sum(calls4animal.C21 == 1 & calls4animal.cluster == 2) / sum(calls4animal.C21 == 1);
% end 
% 
% % cluster 0
% figure; 
% violins = violinplot([df.s0, df.c0]*100, {'Saline','C21'}, 'Width', 0.2); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% ylim([-2 69])
% ylabel('% of cluster 0'); 
% yticks([0 20 40 60])
% plot([1.2,1.8], [df.s0, df.c0]*100, 'k', 'Linewidth', 1.5)
% title(['p = ' num2str(signrank(df.s0, df.c0))])
% 
% % cluster 1
% figure; 
% violins = violinplot([df.s1, df.c1]*100, {'Saline','C21'}, 'Width', 0.2); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% ylim([-2 80])
% ylabel('% of cluster 1'); 
% plot([1.2,1.8], [df.s1, df.c1]*100, 'k', 'Linewidth', 1.5)
% title(['p = ' num2str(signrank(df.s1, df.c1))])
% 
% % cluster 2
% figure; 
% violins = violinplot([df.s2, df.c2]*100, {'Saline','C21'}, 'Width', 0.2); 
% for idx = 1:size(violins, 2)
%     violins(idx).ScatterPlot.MarkerFaceColor = [0 0 0];
%     violins(idx).ScatterPlot.MarkerFaceAlpha = 1;
% end
% set(gca, 'FontSize', 16, 'Fontname', 'Arial', 'Linewidth', 2, 'TickDir', 'out'); 
% ylim([-2 102])
% ylabel('% of cluster 2'); 
% plot([1.2,1.8], [df.s2, df.c2]*100, 'k', 'Linewidth', 1.5)
% title(['p = ' num2str(signrank(df.s2, df.c2))])


