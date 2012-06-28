clear all;
close all;
clc;
esa = figure;
set(esa,'position',[10 400 1800 600]);
for i = 1:6
    f(i)=subplot(2,3,i);
end
for kh = 1%:10
    data = load(['Segmented' num2str(kh) '.mat']);
    for s = 1:length(data.segmented.segmentedStack)
        i = 1;
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).data));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(imfill(data.segmented.segmentedStack(s).mask)));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).vCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).lCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        imshow(mat2gray(data.segmented.segmentedStack(s).gCloseness));
        set(esa,'currentaxes',f(i));,i = i+1;
        sumClose = data.segmented.segmentedStack(s).vCloseness+data.segmented.segmentedStack(s).lCloseness+data.segmented.segmentedStack(s).gCloseness;
        sumClose(find(sumClose < 1.7)) = 0;
        imshow(mat2gray(sumClose));
%         %Laplacian
%         set(esa,'currentaxes',f(i));,i = i+1;
%         laplac = del2(data.segmented.segmentedStack(s).data);
%         imshow(mat2gray(laplac));
%         %Find laplacian zero crossings...
% %         set(esa,'currentaxes',f(i));,i = i+1;
% %         zeroCross = zeros(size(laplac,1)-1,size(laplac,2)-1);
% %         for i = 1:size(laplac,1)-1
% %             for j = 1:size(laplac,2)-1
% %                 if sign(laplac(i,j)) ~= sign(laplac(i,j+1)) || sign(laplac(i,j)) ~= sign(laplac(i+1,j)) || sign(laplac(i,j)) ~= sign(laplac(i+1,j+1))
% %                    zeroCross(i,j) = 1;
% %                 end
% %             end
% %         end
%         set(esa,'currentaxes',f(i));,i = i+1;
%         imshow(mat2gray(edge(data.segmented.segmentedStack(s).data,'canny')));
        
        pause
    end
end
