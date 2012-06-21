clear all;
close all;
clc;
esa = figure;
set(esa,'position',[10 400 1800 600]);
for i = 1:6
    f(i)=subplot(2,3,i)
end
for kh = 1:10
    data = load(['Segmented' num2str(i-2) '.mat']);
    for s = 1:length(data.segmented.segmentedStack)
        i = 1;
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).data));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).mask));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).vCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).lCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).gCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        sumClose = data.segmented.segmentedStack(s).vCloseness+data.segmented.segmentedStack(s).lCloseness+data.segmented.segmentedStack(s).gCloseness;
        sumClose(find(sumClose < 1.9)) = 0;
        imshow(mat2gray(sumClose));
        pause
    end
end
