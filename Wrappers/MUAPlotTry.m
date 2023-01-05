count = 0;
for n = 1:size(MUA,2)
    x = MUA(n).timestamps
    y = MUA(n).amplitude  
    stem(x,y+40*n) 
    count = count + 1000;
    hold on
end

%% 

 %crude version, time vector for plots

imageMatrix = zeros(size(LFP));

for cc = 1:size(LFP,1) 
    for ts = 1:length(MUA(cc).timestamps)
        imageMatrix(cc,MUA(cc).timestamps(ts)) = MUA(cc).amplitude(ts);
    end
end

dsfactor = 1000;

imageMatrixlr = zeros(size(imageMatrix,1),round(length(imageMatrix)/dsfactor)-1);

for mc = 1:length(imageMatrixlr)
    imageMatrixlr(:,mc) = sum(imageMatrix(:,[((mc*dsfactor)-(dsfactor-1)):(mc*dsfactor)]),2);
end

timeVec = linspace(0,length(LFP)/fs-1,length(LFP)/dsfactor);


imagesc([0 timeVec(length(timeVec))],1,imageMatrixlr);
surface(imageMatrixlr);

xlabel('Time(s)');
ylabel('No. of channels');


