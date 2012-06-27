clear all;
close all;
clc;
esa = figure;
set(esa,'position',[10 10 1600 1600]);
for i = 1:4
    f(i)=subplot(2,2,i);
end
for kh = 1%:10
    data = load(['Segmented3Dhisto' num2str(kh) '.mat']);
    for s = 1:size(data.segmented.segmentedStack.data3d,3)
        i = 1;
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack.data3d(:,:,s)));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(imfill(data.segmented.segmentedStack.mask3d(:,:,s))));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack.grayHist3d(:,:,s)));
        
        temp = data.segmented.segmentedStack.grayHist3d(:,:,s);
        temp(find(temp < 0.2)) = 0;
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(temp));
        pause
    end
end
close(esa);