clear all;
    close all;
    clc;
    addpath('max_min_filter');
    javaaddpath('.');
    global segmentedVolume data3d data3v data3l data3g data3m notDone imageHandle subHandle constants;
        
    nHood = strel('disk',2);
    nHoodStack = strel('rectangle',[3 3]);
    kh = 1%:10
        data = load(['SegmentedMin' num2str(kh) '.mat']);
        
        %Original data
        data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        data3m = zeros(size(data.segmented.segmentedStack(1).mCloseness,1),size(data.segmented.segmentedStack(1).mCloseness,2),length(data.segmented.segmentedStack));
        
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) = data.segmented.segmentedStack(s).data;
           data3m(:,:,s) = data.segmented.segmentedStack(s).mCloseness;
           temp = minfilt2(data3d(:,:,s),5,'same');
           temp(find(temp<400)) = 0;
           temp(find(temp > 1100)) = 0;
           minData(:,:,s)  = temp;
           imshow(temp,[]);
           pause
        end
%         temp = minData(:,:,10);
% %         [disto cPoints] = hist(temp(:),15);
% %         plot(disto)
%         
%         figure,imshow(temp,[]);