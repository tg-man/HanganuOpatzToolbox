%% Main baseline spike correlational matrix between areas 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; %function that pulls experimental indicies from your excel file
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCStr\'; 
folder4suainfo = 'Q:\Personal\Tony\Analysis\Results_SUAinfo\'; 

for exp_idx = 1 : size(experiments, 2)
    tic
    experiment = experiments(exp_idx); 

    if experiment.target1 == 1 && experiment.target2 == 1
        % load ACC SUAinfo and extract channel vector 
        load([folder4suainfo 'ACC\' experiment.animal_ID])
        for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
            if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                chs1 = [SUAinfo{1, i}.channel]; 
            end 
        end 
    
        % load Str SUAinfo and extract channel vector 
        load([folder4suainfo 'Str\' experiment.animal_ID])
        for i = 1 : numel(SUAinfo) % find out which cell from SUAinfo to use 
            if strcmp(SUAinfo{1, i}(1).file, experiment.name)
                chs2 = [SUAinfo{1, i}.channel]; 
            end 
        end 

        idx = 1; 
        chvec = []; 
        for unit1 = 1 : numel(chs1) 
            for unit2 = 1 : numel(chs2) 
                chvec(idx, 1) = chs1(unit1); 
                chvec(idx, 2) = chs2(unit2); 
                idx = idx + 1; 
            end 
        end 

        load([folder4STTC experiment.name]); 
        
        STTC = Tcoeff.STTC(:, 3); % the 3rd column is 20ms lag 

        cormat = NaN(16, 16); 
        for ch1_idx = 1 : 16 % first channel loop for ACC probe 
            for ch2_idx = 1 : 16 % second channel loop for Str probe 
                cormat(ch1_idx, ch2_idx) = nanmean(STTC(chvec(:, 1) == ch1_idx & chvec(:, 2) == ch2_idx)); 
            end 
        end 
             
        figure; 
        imagesc(cormat); 
        xlabel('Str Ch'); ylabel('ACC Ch'); title(experiment.animal_ID); 

    end 
    toc 
end 