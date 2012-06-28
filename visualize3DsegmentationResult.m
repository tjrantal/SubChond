function visualize3DsegmentationResult
    clear all;
    close all;
    clc;
   
    global segmentedVolume data3d notDone imageHandle constants;
          addpath('LBP'); %Add LBP functions to path
          constants.lbpMapping=getmapping(16,'riu2');
    nHood = strel('disk',2);
    nHoodStack = strel('rectangle',[3 3]);
    for kh = 1:10
        data = load(['Segmented' num2str(kh) '.mat']);
        
        %Original data
        data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) =  data.segmented.segmentedStack(s).data;
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
         %3D dilate
         disp('Starting flooding');
        segmentedVolume  = flood3d(data3d,segmentedVolume);
        disp('Flooded');
        data3d = data3d/(2*max(max(max(data3d))));
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

    function dilated = flood3d(data3d,segmentedVolume)
        
       meanGrayScale    = mean(data3d(find(segmentedVolume ==1)));
       stdGrayScale     = 3*std(data3d(find(segmentedVolume ==1)));
       dilated = segmentedVolume;
       for s = 1:size(dilated,3)
           init = find(dilated(:,:,s) ==1,1,'first');
           if ~isempty(init)
               tempSlice = squeeze(dilated(:,:,s));
               tempSlice(:,1) = 0;
               tempSlice(1,:) = 0;
               tempSlice(size(tempSlice,1),:) = 0;
               tempSlice(:,size(tempSlice,2)) = 0;
               boundary = bwboundaries(tempSlice,'noholes');
               for b = 1:length(boundary)
                   for ii = 1:length(boundary{b})
                       r = boundary{b}(ii,1);
                       c = boundary{b}(ii,2);
    %                    [r,c] = ind2sub(size(dilated),init(ii));
                       tempR = r;
                       tempC = c;
                        while length(tempR) > 0
                            r = tempR(length(tempR));
                            c = tempC(length(tempC));
                            tempR(length(tempR)) = [];
                            tempC(length(tempC)) = [];
                            if r>1 && r<size(dilated,1) && c>1 && c<size(dilated,2)
                                if dilated(r,c,s) == 0
                                    dilated(r,c,s) =1;
                                end
                                %check whether the neighbour to the left should be added to the queue
                                if dilated(r,c-1,s) == 0 && data3d(r,c-1,s) > (meanGrayScale-stdGrayScale) && data3d(r,c-1,s) < (meanGrayScale+stdGrayScale)
                                    tempR = [tempR r];
                                    tempC = [tempC c-1];
                                end
                                %check whether the neighbour to the right should be added to the queue
                                if dilated(r,c+1,s) == 0 && data3d(r,c+1,s) > (meanGrayScale-stdGrayScale) && data3d(r,c+1,s) < (meanGrayScale+stdGrayScale)
                                    tempR = [tempR r];
                                    tempC = [tempC c+1];
                                end
                                %check whether the neighbour to above should be added to the queue
                                if dilated(r-1,c,s) == 0 && data3d(r-1,c,s) > (meanGrayScale-stdGrayScale) && data3d(r-1,c,s) < (meanGrayScale+stdGrayScale)
                                    tempR = [tempR r-1];
                                    tempC = [tempC c];
                                end
                                %check whether the neighbour to below should be added to the queue
                                if dilated(r+1,c,s) == 0 && data3d(r+1,c,s) > (meanGrayScale-stdGrayScale) && data3d(r+1,c,s) < (meanGrayScale+stdGrayScale)
                                    tempR = [tempR r+1];
                                    tempC = [tempC c];
                                end
                            end
                        end
                   end
               end
           end
        end
    end
end