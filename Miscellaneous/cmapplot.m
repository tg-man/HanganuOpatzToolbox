

for idx = 1:8
    C(idx, :) = YlGnBu(round(100/8*idx),:); 
end 
% C = YlGnBu;
figure; 
imagesc(1:8); 
caxis([1 8]); 
colormap(gca, C); 
% colorbar;
axis off 
set(gca,'YTick',[]);    