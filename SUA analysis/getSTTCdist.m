function Dist = getSTTCdist(experiment, BrainArea, folder4SUAinfo, repeat_calc, save_data, folder4STTCdist)
% Tony Oct. 2023 

% Generate a vector containing distances between STTC paired neurons
% To be used in conjunction with getSTTC_global function
% The order of the output vector is the same as the Tcoeff from getSTTC_global, ie 1-2, 1-3, 1-4, ..., 2-3, 2-4, ..., 3-4, ... The size should match exactly 

if exist([folder4STTCdist BrainArea '\' experiment.name]) && repeat_calc == 0 
    load([folder4STTCdist BrainArea '\' experiment.name]);     

else
    % load SUAinfo
    load([folder4SUAinfo BrainArea '\' experiment.animal_ID]) 

    % compare which cell of SUAinfo to use, then extract channels from that cell only
    for exp_idx = 1 : size(SUAinfo, 2)
        if strcmp({SUAinfo{1, exp_idx}(1).file}, experiment.name) 
            channels = [SUAinfo{1, exp_idx}.channel]'; 
        end 
    end 
    num_units = size(channels, 1); 
    Dist = []; %initialize variables 
    
    % generate matrix of probe geometry according to BrainArea input 
    if strcmp(BrainArea, 'ACC') || strcmp(BrainArea, 'PL')
       probe = reshape(1:16,[4 4]); % 4-shank

        % calculate distance, in the same order as getSTTC_global in a double for loop 
        for unit1 = 1 : num_units 
            for unit2 = unit1 + 1 : num_units

                % find channel positions of current cell pair 
                [r1, c1] = find(probe == channels(unit1)); 
                [r2, c2] = find(probe == channels(unit2)); 

                % calculate distance 
                dist12 = sqrt(((r1 - r2) * 125)^2 + ((c1 - c2) * 100)^2);
                Dist = [Dist; dist12]; 
            end 
        end 

    elseif strcmp(BrainArea, 'Str') || strcmp(BrainArea, 'TH')
        probe = (1:16)'; % 16_50m 

        % calculate distance, in the same order as getSTTC_global in a double for loop 
        for unit1 = 1 : num_units 
            for unit2 = unit1 + 1 : num_units

                % find channel positions of current cell pair 
                p1 = find(probe == channels(unit1)); 
                p2 = find(probe == channels(unit2)); 

                % calculate distance 
                dist12 = abs(50*(p1 - p2));
                Dist = [Dist; dist12]; 
            end 
        end 
    end 

    if save_data == 1 
        if ~ exist([folder4STTCdist BrainArea '\'], 'dir')
            mkdir([folder4STTCdist BrainArea '\']);
        end 
        save([folder4STTCdist BrainArea '\' experiment.name], 'Dist'); 
    end 

end 
     
end % function end 