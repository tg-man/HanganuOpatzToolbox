%% STTC Data for Mattia 

clear; 
experiments = get_experiment_redux;
experiments = experiments([73:232]);
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'opto'));
experiments = experiments(strcmp(extractfield(experiments, 'square'), 'ACCsup'));
experiments = experiments(~(extractfield(experiments, 'IUEconstruct') == 87));

Area = 'ACCdeepTH';
folder4OSTTC = 'Q:\Personal\Tony\Analysis\Results_RampSTTC\';
experiments = experiments(extractfield(experiments, 'target3') == 1);

unitID = 1; 

for exp_idx = 1: size(experiments, 2)
    experiment = experiments(exp_idx); 
    load([folder4OSTTC Area '\' experiment.name]);

    for unit = 1: size(RampSTTC.STTC_pre, 1)
        OptoSTTC(unitID*2 - 1).animal = experiment.animal_ID; 
        OptoSTTC(unitID*2 - 1).unitID = unitID;
        OptoSTTC(unitID*2 - 1).STTC = RampSTTC.STTC_pre(unit, 2);
        OptoSTTC(unitID*2 - 1).stimphase = 'pre';
        OptoSTTC(unitID*2 - 1).IUE = experiment.IUEconstruct; 
        OptoSTTC(unitID*2 - 1).Area = Area; 
    
        OptoSTTC(unitID*2).animal = experiment.animal_ID; 
        OptoSTTC(unitID*2).unitID = unitID; 
        OptoSTTC(unitID*2).STTC = RampSTTC.STTC_during(unit, 2);
        OptoSTTC(unitID*2).stimphase = 'during';
        OptoSTTC(unitID*2).IUE = experiment.IUEconstruct; 
        OptoSTTC(unitID*2).Area = Area; 

        unitID = unitID + 1; 
    end 
  
end 


%% STTC data for R for me 

clear
% load experiments and generic stuff
experiments = get_experiment_redux; 
experiments = experiments(); % what experiments to keep
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only')); 

folder4STTC = 'Q:\Personal\Tony\Analysis\Results_STTC\ACC\'; 
folder4dist = 'Q:\Personal\Tony\Analysis\Results_STTC\Distance\ACC\'; 
% experiments = experiments(extractfield(experiments, 'target3') == 1); 

unit = 1; 
for exp_idx = 1 : numel(experiments) 
    disp(num2str(exp_idx))
    experiment = experiments(exp_idx); 
    load([folder4STTC experiment.animal_ID]);
    load([folder4dist experiment.name]);

    for ci = 1 : size(Dist, 1)
        sttc4r(unit).mouse = experiment.animal_ID;
        sttc4r(unit).age = experiment.age; 
        sttc4r(unit).sttc = Tcoeff.TilingCoeff(ci, 6); % 500ms lag column  
        sttc4r(unit).dist = Dist(ci); 

        unit = unit + 1; 
    end
end 


%% Baseline STTC for Mattia 

clear; 
experiments = get_experiment_redux;
experiments = experiments();
experiments = experiments(strcmp(extractfield(experiments, 'Exp_type'), 'baseline only'));

folder1 = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCsupStr\'; 
folder2 = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCsupTH\'; 
folder3 = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCdeepStr\'; 
folder4 = 'Q:\Personal\Tony\Analysis\Results_STTC\ACCdeepTH\'; 

animal = []; 
STTC = []; 
layer = []; 
area2 = []; 
age = []; 

for exp_idx = 1 : numel(experiments) 
    experiment = experiments(exp_idx); 

    if experiment.target2 == 1 
        load([folder1 experiment.name]); % sup Str
        if ~ isempty(Tcoeff.STTC)
            STTC = [STTC; Tcoeff.STTC(:, 2)]; % 10ms lag
            animal = [animal; repmat({experiment.animal_ID}, [size(Tcoeff.STTC, 1), 1])];
            layer = [layer; repmat({Tcoeff.area1}, [size(Tcoeff.STTC, 1), 1])];
            area2 = [area2; repmat({Tcoeff.area2}, [size(Tcoeff.STTC, 1), 1])];
            age = [age; repmat(experiment.age, [size(Tcoeff.STTC, 1), 1])]; 
        end 
        load([folder3 experiment.name]); % deep Str
        if ~ isempty(Tcoeff.STTC)
            STTC = [STTC; Tcoeff.STTC(:, 2)]; % 10ms lag
            animal = [animal; repmat({experiment.animal_ID}, [size(Tcoeff.STTC, 1), 1])];
            layer = [layer; repmat({Tcoeff.area1}, [size(Tcoeff.STTC, 1), 1])];
            area2 = [area2; repmat({Tcoeff.area2}, [size(Tcoeff.STTC, 1), 1])];
            age = [age; repmat(experiment.age, [size(Tcoeff.STTC, 1), 1])]; 
        end 
    end 

    if experiment.target3 == 1 
        load([folder2 experiment.name]); % sup TH
        if ~isempty(Tcoeff.STTC)
            STTC = [STTC; Tcoeff.STTC(:, 2)]; % 10ms lag
            animal = [animal; repmat({experiment.animal_ID}, [size(Tcoeff.STTC, 1), 1])];
            layer = [layer; repmat({Tcoeff.area1}, [size(Tcoeff.STTC, 1), 1])];
            area2 = [area2; repmat({Tcoeff.area2}, [size(Tcoeff.STTC, 1), 1])];
            age = [age; repmat(experiment.age, [size(Tcoeff.STTC, 1), 1])]; 
        end 
        load([folder4 experiment.name]); % deep TH
        if ~isempty(Tcoeff.STTC)
            STTC = [STTC; Tcoeff.STTC(:, 2)]; % 10ms lag
            animal = [animal; repmat({experiment.animal_ID}, [size(Tcoeff.STTC, 1), 1])];
            layer = [layer; repmat({Tcoeff.area1}, [size(Tcoeff.STTC, 1), 1])];
            area2 = [area2; repmat({Tcoeff.area2}, [size(Tcoeff.STTC, 1), 1])];
            age = [age; repmat(experiment.age, [size(Tcoeff.STTC, 1), 1])]; 
        end 
    end 
end 






