close all;
clear all;

Nexperiment = [14];
pulseLength = 3; %in ms
Path='Q:\Personal\Anton\ExperimentPlan.xlsx';

experiments_prelim=get_experiment_list(Path,Nexperiment);

resultsdir_main='Q:\Personal\Anton\LFP_from_MatLab\';

groups={'MHC'}; %% just run if only certain groups required->ExpType
Num1=0;
for f1=1:size(experiments_prelim,1)
    if ~isempty(experiments_prelim(f1).Basic.General.animalID) && sum(isnan(experiments_prelim(f1).Recordings.Recording.RecordingName))==0
        if any(strcmp(experiments_prelim(f1).Basic.General.ExpType,groups)) % with ~ exclude, without ~ only include
            Num1=Num1+1;
            experiments1(Num1,1)=experiments_prelim(f1);
        end
    end
end
inum=0;
for e1 = 1:length(experiments1)
    if  (experiments1(e1).Recordings.General.Use) == 1
        inum = inum+1;
        experiments2 (inum,1) = experiments1(e1);
    else
    end
end
experiments=experiments2;
clear experiments1 experiments2 experiments_prelim Nexperiment
%%

Animal=num2str(experiments(f1).Basic.General.animalID);
RecNo=num2str(experiments(f1).Recordings.General.RecNo);
datadir=strcat(experiments(f1).Recordings.Recording.RecordingPath,experiments(f1).Recordings.Recording.RecordingName,'\');
savedir=strcat(resultsdir_main,'AwakeBaselineAnalysis\',Animal,'\',num2str(RecNo),'\');

%[StimulationProperties,BaselinePeriods]=StimulationPropertiesBaselinePeriods(datadir);

CSCs = str2num(experiments.Recordings.Recording.SpecialCSCsMUA);
[~,forFindingEnd,~]=load_nlx_Modes(strcat(datadir,'CSC',num2str(CSCs(1)),'.ncs'),1,[]);

endOfRec = length(forFindingEnd);

timevec = linspace(0,endOfRec/32000-1,endOfRec);

[~,pulses,~]=load_nlx_Modes(strcat(datadir,'STIM1D.ncs'),2,[1 endOfRec]);
pulses = pulses./1000;

pulseDiff = diff(pulses);

pulseDiff2 = zeros(size(pulseDiff));

starts = find(pulseDiff > 1);
ends = find(pulseDiff < -1);

for pp = 1:length(starts)
    pulseDiff2(starts(pp)) = 1;
end
for pp = 1:length(ends)
    pulseDiff2(ends(pp)) = 1;
end

pulseDiff3 = diff(pulseDiff2);

pulseSEIndices = find(pulseDiff3==1);
plotIndices = zeros(size(pulseSEIndices));

for pb = 1:2:length(pulseSEIndices)-1
    plotIndices(pb) = pulseSEIndices(pb)-(32000/20); %starting 50ms before pulse
    plotIndices(pb+1) = pulseSEIndices(pb)+(32000*0.103); %ending 100ms after pulse
end



figure(1);
rectangle('Position',[0 0 pulseLength (length(plotIndices)*0.5*length(CSCs))],'FaceColor', 'b', 'EdgeColor', 'none');
xlabel('Time(ms)');
ylabel('MUA of each channel and each light-pulse')
hold on
count = 0;
timevecPulse = linspace(-50,103,32000*0.153);
for nsc = 1:length(CSCs)
    disp(strcat('channel ',num2str(nsc),'/',num2str(length(CSCs))));
    [~,samples,fs]=load_nlx_Modes(strcat(datadir,'CSC',num2str(CSCs(nsc)),'.ncs'),2,[1 endOfRec]);
    lc=500;
    hc=9000;
    samplesMUA=ZeroPhaseFilterZeroPadding(samples,fs,[lc hc]);
    
    thr = std(samplesMUA) * 4;
    [peakLoc, Ampl] = peakfinderOpto(samplesMUA, thr/2 , -thr, -1);
    peaks = NaN(size(samplesMUA));
    for etp = 1:length(peakLoc)
        peaks(peakLoc(etp)) = 1;
    end
    
      hold on
      peaks = peaks + count;
    for px = 1:2:length(plotIndices)-1
        count = count + 1;
%         disp(strcat(num2str((count*100)/length(plotIndices)*0.5*length(CSCs)),'%'));
        peaks = peaks + 1;
        scatter(timevecPulse,peaks(plotIndices(px):plotIndices(px+1)-1),'.','k');
        ylim([0 (length(plotIndices)*0.5*length(CSCs))+200])
        xlim([-50 103])
        hold on
    end
    clear samples
end

plot(timevecPulse,pulses(plotIndices(1):plotIndices(2)-1)+(length(plotIndices)*0.5*length(CSCs))+50,'b');
