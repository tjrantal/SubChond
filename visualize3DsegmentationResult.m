function visualize3DsegmentationResult
    clear all;
    close all;
    clc;
   
    global segmentedVolume data3d notDone imageHandle;
    nHood = strel('disk',2);
    nHoodStack = strel('rectangle',[3 3]);
    for kh = 1:10
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
            segment3d(r,:,:) =  imdilate(imfill(imerode(squeeze(segment3d(r,:,:)),nHoodStack)),nHoodStack);
        end
        for c = 1:size(segment3d,2)
            segment3d(:,c,:) =  imdilate(imfill(imerode(squeeze(segment3d(:,c,:)),nHoodStack)),nHoodStack);
        end
        for s = 1:size(segment3d,3)
           segment3d(:,:,s) =  imfill(imerode(squeeze(segment3d(:,:,s)),nHood));
        end
        
        %Get connected volumes
        
        ConnectedVolumes = bwconncomp(segment3d,6); %Using 6 connected neigbourhood
        disp(['Number of connected volumes' num2str(ConnectedVolumes.NumObjects)  ' subject ' num2str(kh)]);
        numPixels = cellfun(@numel,ConnectedVolumes.PixelIdxList);
        
        %Select second largest volume. The largest is femur, second largest
        %tibia...
        %check whether femur was found at all...
        
        for v = 1:2
            [biggest,idx] = max(numPixels);
            [X,Y,Z] = ind2sub(size(segment3d),ConnectedVolumes.PixelIdxList{idx});
            centre(:,v) = [mean(X),mean(Y),mean(Z)];
            objectInd(v) = idx;
            numPixels(idx) = 0;
        end
        if centre(1,1) < 300
            selectedObject = objectInd(2);
        else
            selectedObject = objectInd(1);
        end

        segmentedVolume = zeros(size(segment3d,1),size(segment3d,2),size(segment3d,3));
        segmentedVolume(ConnectedVolumes.PixelIdxList{selectedObject}) = 1;
        initR = floor((size(data3d,1)-size(segmentedVolume,1))/2)+1;
        initC = floor((size(data3d,2)-size(segmentedVolume,2))/2)+1;
        %Remove edges from original data to match the segmented data...
        data3d = data3d(initR:(initR+size(segmentedVolume,1)-1),initC:(initC+size(segmentedVolume,2)-1),:);
        data3d = data3d/2*(max(max(max(data3d))));
        data3d(find(segmentedVolume ==1)) = data3d(find(segmentedVolume ==1))+0.5;
        esa = figure;
        sliceToShow = 1;
        imageHandle = imshow(squeeze(data3d(:,:,sliceToShow)),[]);
         title(['Fig ' num2str(sliceToShow)]);
         notDone = 1;
        set(esa,'position',[10 10 800 800],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
        slaideri = uicontrol(esa,'style','slider','min',1,'max', length(data.segmented.segmentedStack)+0.99, ...
        'value',1,'callback',@setFig, ...
        'units','normalized','position',[0.2,0.05,0.6,0.05],'sliderstep',[1/(length(data.segmented.segmentedStack)-1) 1/(length(data.segmented.segmentedStack)-1)]);
        notDone = 1;
        while notDone
            pause(1); 
        end
        disp(['Done ' num2str(kh)]);
    end
    
    function setFig(obj,evt)
        sliceToShow = floor(get(obj,'Value'));
        set(imageHandle,'CData',squeeze(data3d(:,:,sliceToShow)));
        title(['Fig ' num2str(sliceToShow)]);
    end

    function doneWithTheStack(obj,evt)
        notDone = 0;
        delete(esa);
    end
end