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
        [biggest,idx] = max(numPixels);
        tempVolume = zeros(size(data3d,1),size(data3d,2),size(data3d,3));
        tempVolume(ConnectedVolumes{idx}) = 1;
        numPixels(idx) = 0;
        
        
        %Plottaa 3D
        for i = 1:2
            esa2 = figure;
            set(esa2,'Renderer','OpenGL')
            [pinnat,kulmat]  = isosurface(tempVolume,0);
            %faceColor = [249/256,237/256,215/256]; %Bone
            faceColor = [0,0,0]; %Bone
            hiso1 = patch('faces',pinnat,'vertices',kulmat,...
                'FaceColor',faceColor,...
                'EdgeColor','none','facealpha',0.5);
            daspect([1,1,1/13.1675]);
            lighting gouraud;
            kpiste(1) = size(data3d,1)/2;
            kpiste(2) = size(data3d,2)/2;
            kpiste(3) = size(data3d,3)/2*13.1675;
            vektori = [4000; 4000; 4000];
            %  set(gca,'cameraviewanglemode','auto')
            set(gca,'cameraposition',[kpiste(1)+vektori(1),kpiste(2)+vektori(2),kpiste(3)+4000],'cameraviewangle',3);
        end
        keyboard
        esa = figure;
        for i = 1:3
            f(i)=subplot(1,3,i)
            hold on;
        end

        i = 1;
        set(esa,'currentaxes',f(i));,i = i+1;
        imH(1) = imshow(squeeze(data3d(:,:,1)),[]);
        lines(1) = plot([1,1],[1,size(data3d,1)],'b');
        lines(2) = plot([1,size(data3d,2)],[1,1],'r');
        set(esa,'currentaxes',f(i));,i = i+1;
        imH(2) = imshow(squeeze(data3d(:,1,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,1)]);
        axis equal
        set(esa,'currentaxes',f(i));,i = i+1;
        imH(3) = imshow(squeeze(data3d(1,:,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,2)]);
        axis equal

        set(esa,'position',[10 10 1800 600],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
%         keyboard
        %Depth
        slaideri(1) = uicontrol(esa,'style','slider','string','depth','min',1,'max', length(data.segmented.segmentedStack)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.05,0.6,0.05],'sliderstep',[1/(length(data.segmented.segmentedStack)-1) 1/(length(data.segmented.segmentedStack)-1)]);
        
        %Width
        slaideri(2) = uicontrol(esa,'style','slider','string','width','min',1,'max', size(data.segmented.segmentedStack(1).data,2)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.15,0.6,0.05],'sliderstep',[1/(size(data.segmented.segmentedStack(1).data,2)-1) 1/(size(data.segmented.segmentedStack(1).data,2)-1)]);
        
        %Height
        slaideri(3) = uicontrol(esa,'style','slider','string','height','min',1,'max', size(data.segmented.segmentedStack(1).data,1)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.25,0.6,0.05],'sliderstep',[1/(size(data.segmented.segmentedStack(1).data,1)-1) 1/(size(data.segmented.segmentedStack(1).data,1)-1)]);
        
        %Wait for the user to finish with the stack...
        
        notDone = 1;
        while notDone
           pause(1); 
        end

        
    end
        function setFig(obj,evt)
    %          global data;
             sliceToShow = floor(get(obj,'Value'));
             string = get(obj,'string');

             if strcmp(string,'depth')
                 set(gcf,'currentaxes',f(1));
%                 imshow(squeeze(data3d(:,:,sliceToShow)),[]);
                set(imH(1),'CData',mat2gray(squeeze(data3d(:,:,sliceToShow))));
                lines(1) = plot(get(lines(1),'xdata'),get(lines(1),'ydata'),'b');
                lines(2) = plot(get(lines(2),'xdata'),get(lines(2),'ydata'),'r');
             end
             if strcmp(string,'width')
                   %Plot horizontal line to indicate where we are...
                 set(lines(1),'xdata',[sliceToShow sliceToShow]);
                 
                set(gcf,'currentaxes',f(2));
                set(imH(2),'CData',mat2gray(squeeze(data3d(:,sliceToShow,:))));
%                 imshow(squeeze(data3d(:,sliceToShow,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,1)]);
%                 axis equal;
                
             end
            if strcmp(string,'height')
                
                set(lines(2),'ydata',[sliceToShow sliceToShow]);
                set(gcf,'currentaxes',f(3));
%                 imshow(squeeze(data3d(sliceToShow,:,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,2)]);
                set(imH(3),'CData',mat2gray(squeeze(data3d(sliceToShow,:,:))));
                axis equal;
             end
             title(['Fig ' num2str(sliceToShow)]);
             drawnow;
        end

        function doneWithTheStack(obj,evt)
            notDone = 0;
            delete(esa);
        end
end