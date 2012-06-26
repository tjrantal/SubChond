function visualizeSlices
    global esa f notDone data3d slaideri lines;
    clear all;
    close all;
    clc;
   
    for kh = 1%:10
        data = load(['Segmented' num2str(kh) '.mat']);
        
        data3d = zeros(size(data.segmented.segmentedStack(1).mask,1),size(data.segmented.segmentedStack(1).mask,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) =  imfill(data.segmented.segmentedStack(s).mask);
        end
        for r = 1:size(data3d,1)
            data3d(r,:,:) =  imfill(squeeze(data3d(r,:,:)));
        end
        for c = 1:size(data3d,2)
            data3d(:,c,:) =  imfill(squeeze(data3d(:,c,:)));
        end
%         data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
%         %Get 3D stack
%         for s = 1:length(data.segmented.segmentedStack)
%            data3d(:,:,s) =  data.segmented.segmentedStack(s).data;
%         end
        
        ConnectedVolumes = bwconncomp(data3d,6);
        numPixels = cellfun(@numel,ConnectedVolumes.PixelIdxList);
 
        
        esa = figure;
        set(esa,'Renderer','OpenGL')
        set(esa,'position',[10 10 1800 600],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
        %Plottaa 3D
        for i = 1:2
            [biggest,idx] = max(numPixels);
            tempVolume = zeros(size(data3d,1),size(data3d,2),size(data3d,3));
            tempVolume(ConnectedVolumes.PixelIdxList{idx}) = 1;
            subplot(1,2,i);
            [pinnat,kulmat]  = isosurface(tempVolume,0);
            %faceColor = [249/256,237/256,215/256]; %Bone
            faceColor = [0,0,0]; %Bone
            hiso1 = patch('faces',pinnat,'vertices',kulmat,...
                'FaceColor',faceColor,...
                'EdgeColor','none','facealpha',0.5);
            daspect([1,1,1/13.1675]);
            lighting gouraud;
            kpiste(1) = size(tempVolume,1)/2;
            kpiste(2) = size(tempVolume,2)/2;
            kpiste(3) = size(tempVolume,3)/2*13.1675;
            vektori = [4000; 4000; 4000];
            %  set(gca,'cameraviewanglemode','auto')
            set(gca,'cameraposition',[kpiste(1)+vektori(1),kpiste(2)+vektori(2),kpiste(3)+400],'cameraviewangle',3);
            numPixels(idx) = 0;
        end
        
        %Wait for the user to finish with the stack...
        
        notDone = 1;
        while notDone
           pause(1); 
        end

        
    end
  
        function doneWithTheStack(obj,evt)
            notDone = 0;
            delete(esa);
        end
end