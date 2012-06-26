   clear all;
    close all;
    clc;
   addpath('vol3dv2'); %Add LBP functions to path

    for kh = 1%:10
        data = load(['Segmented' num2str(kh) '.mat']);
        
        %Original data
        data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) =  mat2gray(data.segmented.segmentedStack(s).data);
        end
        
        %Segmented data
        segment3d = zeros(size(data.segmented.segmentedStack(1).mask,1),size(data.segmented.segmentedStack(1).mask,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        disp(['Starting segmentation subject ' num2str(kh)]);
        for s = 1:length(data.segmented.segmentedStack)
           segment3d(:,:,s) =  imfill(data.segmented.segmentedStack(s).mask);
        end
        for r = 1:size(segment3d,1)
            segment3d(r,:,:) =  imfill(squeeze(segment3d(r,:,:)));
        end
        for c = 1:size(segment3d,2)
            segment3d(:,c,:) =  imfill(squeeze(segment3d(:,c,:)));
        end
        for s = 1:size(segment3d,3)
           segment3d(:,:,s) =  imfill(squeeze(segment3d(:,:,s)));
        end
        
        %Get connected volumes
        disp(['Conneced volumes subject ' num2str(kh)]);
        ConnectedVolumes = bwconncomp(segment3d,6); %Using 6 connected neigbourhood
        numPixels = cellfun(@numel,ConnectedVolumes.PixelIdxList);
        
        %Select second largest volume. The largest is femur, second largest
        %tibia...
        for v = 1:2
            [biggest,idx] = max(numPixels);
            numPixels(idx) = 0;
        end
        segmentedVolume = zeros(size(segment3d,1),size(segment3d,2),size(segment3d,3));
        segmentedVolume(:) = 0.1;
        segmentedVolume(ConnectedVolumes.PixelIdxList{idx}) = 1;
        disp(['Visualizing ' num2str(kh)]);
        initR = floor((size(data3d,1)-size(segmentedVolume,1))/2)+1;
        initC = floor((size(data3d,2)-size(segmentedVolume,2))/2)+1;
        vol3d('CData',data3d(initR:(initR+size(segmentedVolume,1)-1),initC:(initC+size(segmentedVolume,2)-1),:),'Alpha',segmentedVolume);
        colormap('gray');
        xLimits = get(gca,'xlim');
        yLimits = get(gca,'ylim');
        zLimits = get(gca,'xlim');
        set(gca,'cameraupvector',[0 0 -1]);
         set(gca,'cameraposition',[mean(xLimits),mean(yLimits)+400,mean(zLimits)+400],'cameraviewangle',3);
        disp(['Done ' num2str(kh)]);
    end