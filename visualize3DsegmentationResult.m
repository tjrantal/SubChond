function visualize3DsegmentationResult
    clear all;
    close all;
    clc;
    addpath('max_min_filter');
    javaaddpath('.');
    global segmentedVolume data3d data3v data3l data3g data3m notDone imageHandle subHandle constants;
        
    nHood = strel('disk',2);
    nHoodStack = strel('rectangle',[3 3]);
    for kh = 2%:10
        data = load(['Segmented' num2str(kh) '.mat']);
        
        %Original data
        data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        data3v = zeros(size(data.segmented.segmentedStack(1).vCloseness,1),size(data.segmented.segmentedStack(1).vCloseness,2),length(data.segmented.segmentedStack));
        data3l = zeros(size(data.segmented.segmentedStack(1).lCloseness,1),size(data.segmented.segmentedStack(1).lCloseness,2),length(data.segmented.segmentedStack));
        data3g = zeros(size(data.segmented.segmentedStack(1).gCloseness,1),size(data.segmented.segmentedStack(1).gCloseness,2),length(data.segmented.segmentedStack));
        data3m = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) =  data.segmented.segmentedStack(s).data;
           data3v(:,:,s) =  data.segmented.segmentedStack(s).vCloseness;
           data3l(:,:,s) =  data.segmented.segmentedStack(s).lCloseness;
           data3g(:,:,s) =  data.segmented.segmentedStack(s).gCloseness;
           tempMin = minfilt2(squeeze(data3d(:,:,s)),5,'same');
           data3m(:,:,s) = tempMin/max(max(tempMin));
        end
%         keyboard;
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
        data3m = data3m(initR:(initR+size(segmentedVolume,1)-1),initC:(initC+size(segmentedVolume,2)-1),:);
        data3m = data3m/max(max(max(data3m)));
         %3D dilate
%           keyboard;
         disp('Starting flooding');
        segmentedVolume  = flood3d(segmentedVolume);
        disp('Flooded');
        data3d = data3d/(2*max(max(max(data3d))));
        data3d(find(segmentedVolume ==1)) = data3d(find(segmentedVolume ==1))+0.1;
        esa = figure;
        for i = 1:2
           subHandle(i) = subplot(1,2,i); 
        end
        sliceToShow = 1;
        i = 1;
        set(esa,'currentaxes',subHandle(i));
        imageHandle(i) = imshow(squeeze(data3d(:,:,sliceToShow)),[]);
         title(['Fig ' num2str(sliceToShow)]);
         i=i+1;

%         set(esa,'currentaxes',subHandle(i));
%         imageHandle(i) = imshow(squeeze(data3v(:,:,sliceToShow)),[]);
%          title(['Fig v' num2str(sliceToShow)]);
%          i=i+1;

                 set(esa,'currentaxes',subHandle(i));
        imageHandle(i) = imshow(squeeze(data3m(:,:,sliceToShow)),[]);
         title(['Fig l' num2str(sliceToShow)]);
         i=i+1;
         
%                           set(esa,'currentaxes',subHandle(i));
%         imageHandle(i) = imshow(squeeze(data3g(:,:,sliceToShow)),[]);
%          title(['Fig l' num2str(sliceToShow)]);
%          i=i+1;
         
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
        
               i = 1;
        set(esa,'currentaxes',subHandle(i));
         set(imageHandle(i),'CData',squeeze(data3d(:,:,sliceToShow)));
         title(['Fig ' num2str(sliceToShow)]);
         i=i+1;

%         set(esa,'currentaxes',subHandle(i));
%         set(imageHandle(i),'CData',squeeze(data3v(:,:,sliceToShow)));
%          title(['Fig v' num2str(sliceToShow)]);
%          i=i+1;

         set(esa,'currentaxes',subHandle(i));
%          toPlot = squeeze(data3l(:,:,sliceToShow));
%          toPlot2 = squeeze(data3v(:,:,sliceToShow));
%          toPlot2(find(toPlot2 < 0.7)) = 0;
%          toPlot3 = squeeze(data3g(:,:,sliceToShow));
%          toPlot3(find(toPlot3 < 0.7)) = 0;
%          toPlot(find(toPlot < 0.7)) = 0;
         set(imageHandle(i),'CData',mat2gray(squeeze(data3m(:,:,sliceToShow))));
         %set(imageHandle(i),'CData',mat2gray(toPlot+toPlot2+toPlot3));
         title(['Fig l' num2str(sliceToShow)]);
         i=i+1;
         
%           set(esa,'currentaxes',subHandle(i));
%           set(imageHandle(i),'CData',squeeze(data3g(:,:,sliceToShow)));
%          title(['Fig g' num2str(sliceToShow)]);
%          i=i+1;

    end

    function doneWithTheStack(obj,evt)
        notDone = 0;
        delete(esa);
    end

    function dilated = flood3d(segmentedVolume)
       global meanGrayScale stdGrayScale;
       meanGrayScale    = mean(data3m(find(segmentedVolume ==1)));
       stdGrayScale     = 4*std(data3m(find(segmentedVolume ==1)));
       dilated = segmentedVolume;
       for s = 1:size(dilated,3)
           init = find(dilated(:,:,s) ==1,1,'first');
           if ~isempty(init)
               tempSlice = squeeze(dilated(:,:,s));
               tempSlice(:,1) = 0;
               tempSlice(1,:) = 0;
               tempSlice(size(tempSlice,1),:) = 0;
               tempSlice(:,size(tempSlice,2)) = 0;
               boundaries = bwboundaries(tempSlice,'noholes');
               for b = 1:length(boundaries)
                   for ii = 1:length(boundaries{b})
                       r = boundaries{b}(ii,1);
                       c = boundaries{b}(ii,2);
                        javaFlooded = javaLoop.JavaDilate(squeeze(dilated(:,:,s)), squeeze(data3m(:,:,s)), r, c, [meanGrayScale-stdGrayScale meanGrayScale+stdGrayScale]);
                        dilated(:,:,s) = javaFlooded.dilated;
                        clear javaFlood;
                   end
               end
           end
        end
    end
    
    %Dilate decision based on min filtered image
    function [tempR tempC] = checkScale(dilated,lr,lc,s,tempR,tempC)
        global meanGrayScale stdGrayScale;
         if dilated(lr,lc,s) == 0 && ...
            data3m(lr,lc,s) > meanGrayScale-stdGrayScale && ...
            data3m(lr,lc,s) < meanGrayScale+stdGrayScale
            tempR = [tempR lr];
            tempC = [tempC lc];
        end
    end

%     %Closeness stuff  
%     function [tempR tempC] = checkScale(dilated,lr,lc,s,tempR,tempC)
%          if dilated(lr,lc,s) == 0 && ( ...
%                 (data3v(lr,lc,s) > 0.7 && data3l(lr,lc,s) > 0.7) ...
%              || (data3v(lr,lc,s) > 0.7 && data3g(lr,lc,s) > 0.7) ...
%              || (data3l(lr,lc,s) > 0.7 && data3g(lr,lc,s) > 0.7) ...
%              )
%             tempR = [tempR lr];
%             tempC = [tempC lc];
%         end
%     end
end