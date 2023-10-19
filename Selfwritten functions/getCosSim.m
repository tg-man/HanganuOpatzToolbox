function [similarity, angle] = getCosSim(vector1, vector2)
% Tony July, 2023 

% script to calculate cosine similarity
% tldr: https://www.learndatasci.com/glossary/cosine-similarity/#:~:text=Both%20vectors%20need%20to%20be,of%20the%20angle%20between%20them.
% input: 
%     - two vectors, equal length, row or column 
%     
% output: 
%     - a single number of cosine similarty between the two vectors 
%     - the corresponding angle in radian 
    
similarity = dot(vector1, vector2) / (norm(vector1)*norm(vector2));
angle = acos(similarity);

end 
