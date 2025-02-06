
clear 

T = readtable('Q:\Lab protocols\TVAs\N015-2018\Disc Animals.xlsx', 'Sheet', 'ab 07.05.20 OG');
T = T(1:90, :)
com = T.Comments;

pd = []; 

for idx = 1 : size(com, 1)
    text = com{idx}; 
    if contains(text, 'Plug pos. ')
        pd{idx, 1} = text(strfind(text, 'Plug pos. ')+10 :  strfind(text, 'Plug pos. ')+17)
    elseif contains(text, 'Plug am ')
        pd{idx, 1} = text(strfind(text, 'Plug am ')+8 :  strfind(text, 'Plug am ')+15)
    end     
end 

regexp(text, 'Plug pos. ')