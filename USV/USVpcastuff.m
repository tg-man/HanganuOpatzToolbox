
clear
experiments = get_experiment_redux;
experiments = experiments(256:281);  
save_data = 1; 

file = 'Q:\Personal\Tony\Analysis\Results_USV\Stats\T0000042 2024-01-24  5_36 PM_Stats.xlsx'; 

[USVstats, len_rec] = getUSVstats(file); 
