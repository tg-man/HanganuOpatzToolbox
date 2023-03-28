%% By Mattia
function [stimulationTimeStamps] = getStimulationTimeStampsHenrik(experiment, save_data, folder2save)

filename = strcat(experiment.path, filesep, experiment.name, filesep, 'STIM1D.ncs');

FieldSelectionArray     = [0 0 1 0 1]; %TimeStamps, ChannelNumbers, SampleFrequencies, NumberValidSamples, Samples
ExtractHeaderValue      = 0;
ExtractMode             = 1;
ExtractModeArray        = [];
[SampleFrequencies, Samples] = Nlx2MatCSC(filename, FieldSelectionArray, ExtractHeaderValue, ExtractMode, ExtractModeArray);

clear TimeStamps
f = median(SampleFrequencies);
clear SampleFrequencies

% rearray and adjust
Samples = reshape(Samples, 1, size(Samples, 1) * size(Samples, 2));
Samples = Samples ./ 32.81; %adjust to microVolt; only for LFP
Samples = Samples > max(Samples) * 0.5;

%% find stimulus period
StimDStart = find(diff(Samples) == 1) + 1;
StimDEnd = find(diff(Samples) == - 1) - 1;
StimDshortinterval = find(diff(StimDStart) < f) + 1;
StimDStart(StimDshortinterval) = [];
StimDEnd(StimDshortinterval - 1) = [];

StimStart = StimDStart; % leave it in timestamps
StimEnd = StimDEnd; % leave it in timestamps

stimulationTimeStamps = [StimStart',StimEnd'];

%% Save
if save_data == 0 || isempty(stimulationTimeStamps)
    return
else
    save([folder2save, experiment.name, '_SUAstimulatioTimeStamps'],'stimulationTimeStamps');
end
end