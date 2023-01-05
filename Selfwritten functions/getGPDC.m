function [gPDC] = getGPDC(signal_1, signal_2, fs, high_cut, animal_ID, area_1, area_2, save_data, result_path)
% modified by Tony, Oct. 2022 
% Original script written by Xiaxia and obtained from Yunan.

% calculates gPDC between the two signals at different frequencies. 

% inputs: 
%       signal_1&2: equal length, each row should be a time series
%       area_1&2: name of the brain areas in strings 
%    	fs: sampling rate of signals, Hz 
%   	high_cut: high end of the frequency spectrum 
%       animal_ID: used to name final file, extract from experiment file in
%       loop 
%   	save_data: whether to save the output. 1 = yes, 0 = no 
%   	result path: directory to save the results 

% Outputs: a structure containing different informations 
% important output
%         c.c12 - the strength of signal_2 driving signal_1
%         c.c21 - the strength of signal_1 driving signal_2

% dependent on another function (PDC_computation) which depends on many
% other subfunctions. 
% Parameters PDC_computation is written as default values but can be
% changed in the function itself. 

window_length = 1; % in seconds
nFreqs = 512; % number of frequency bins 
lenWind = window_length * fs; % window length, from seconds to frames 
numWind = floor(2*length(signal_1)/lenWind) - 1; % number of total windows with 50% overlap each sliding step
f = fs/(2*nFreqs):fs/(2*nFreqs):high_cut; % frequency vectors 

% de-noise parameters 
N = 4; 
wname='db4';

% PDC_computation parameters 
metric = 'diag';
maxIP = 50;
alg = 1;
criterion = 1;
flag_mvarresidue = 1;
alpha = 0; 

% initialize two gPDC matrix
c12 = []; c21 = [];

% actual gPDC calculation part, looping window by window
for num = 1:numWind
    
    S = (num-1)*lenWind/2+1;
    E = (num+1)*lenWind/2;   
    x = detrend(signal_1(S:E));
    y = detrend(signal_2(S:E));
    
    % de-noise and reconstruct a new signal with less noise  
    [THR,SORH,KEEPAPP] = ddencmp('den','wp',x); 
    x=wdencmp('gbl',x, wname,N,THR,SORH,KEEPAPP) ;   
    [THR,SORH,KEEPAPP] = ddencmp('den','wp',y);
    y=wdencmp('gbl',y, wname,N,THR,SORH,KEEPAPP) ;
        
    u=[x' y']; % put signal into one matrix as required for the next function 
    c = PDC_computation(u,nFreqs,metric,maxIP,alg,alpha,criterion,flag_mvarresidue);        
    if ~isempty(c) % input the values into gPDC matrix with each loop/window 
        c12=[c12, c.c12];
        c21=[c21, c.c21];  
    end
end

% take the median of all windows (over the entire signal duration)
c12 = nanmedian(c12,2); 
c21 = nanmedian(c21,2); 

% Put everything in a structure 
gPDC.c12 = c12; 
gPDC.c21 = c21; 
gPDC.Area1 = area_1; 
gPDC.Area2 = area_2; 
gPDC.len_win = window_length; 
gPDC.fs = fs; 
gPDC.f = f;
gPDC.animal_ID = animal_ID; 
gPDC.Note = 'c12: 2 driving 1. c21: 1 driving 2'; 

if save_data == 1
    save(strcat(result_path, animal_ID,'_', area_1, '_', area_2),'gPDC'); 
end 
end 


