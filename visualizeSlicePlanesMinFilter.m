function visualizeSlices
    global esa f notDone data3d slaideri lines imH;
    clear all;
    close all;
    clc;
   addpath('max_min_filter');
    filter = fspecial('gaussian');
    
    
    for kh = 1%:10
        data = load(['Segmented' num2str(kh) '.mat']);
        
        data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        minCoronal = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        minSagittal = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        minAxial = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
        %Get 3D stack and fill voids
        for s = 1:length(data.segmented.segmentedStack)
           data3d(:,:,s) =  data.segmented.segmentedStack(s).data;
           
           minCoronal(:,:,s) = minfilt2(data3d(:,:,s),5,'same');
%            minCoronal(:,:,s) = timoMinfilt(data3d(:,:,s),[5 3 3]);
        end
        
        
%         minCoronal = timoMinFilt(data3d,[5 5 3]);
        for c = 1:size(minSagittal,2)
            minSagittal(:,c,:) = minfilt2(squeeze(data3d(:,c,:)),3,'same');
        end
        for r = 1:size(minAxial,1)
%             minAxial(r,:,:) = minfilt2(squeeze(data3d(r,:,:)),3,'same');
            minAxial(r,:,:) = squeeze(data3d(r,:,:));
        end
        
%         minSagittal(find(minSagittal < 500)) = 0;
%         minSagittal(find(minSagittal > 1200)) = 0;
%         minAxial(find(minAxial < 500)) = 0;
%         minAxial(find(minAxial > 1200)) = 0;
        
        esa = figure;

        for i = 1:3
            f(i) = subplot(1,3,i);
        end
            
            i = 1;
        set(esa,'currentaxes',f(i));i = i+1;
        imH(1) = imshow(mat2gray(squeeze(minCoronal(:,:,1))));
        hold on;
        lines(1) = plot([1,1],[1,size(data3d,1)],'b');
        lines(2) = plot([1,size(data3d,2)],[1,1],'r');
        set(esa,'currentaxes',f(i));i = i+1;
        imH(2) = imshow(squeeze(minSagittal(:,1,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,1)]);
        hold on;
        lines(3) = plot([1,1],[1,size(data3d,1)],'g');
        lines(4) = plot([1,250],[1,1],'r');
        axis equal
        set(esa,'currentaxes',f(i));i = i+1;
        imH(3) = imshow(squeeze(minAxial(1,:,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,2)]);
        hold on;
        lines(5) = plot([1,1],[1,size(data3d,1)],'g');
        lines(6) = plot([1,250],[1,1],'b');
        axis equal

        set(esa,'position',[10 400 1800 600],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
%         keyboard
        %Depth
        slaideri(1) = uicontrol(esa,'style','slider','string','depth','min',1,'max', length(data.segmented.segmentedStack)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.01,0.6,0.03],'sliderstep',[1/(length(data.segmented.segmentedStack)-1) 1/(length(data.segmented.segmentedStack)-1)]);
        
        %Width
        slaideri(2) = uicontrol(esa,'style','slider','string','width','min',1,'max', size(data.segmented.segmentedStack(1).data,2)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.05,0.6,0.03],'sliderstep',[1/(size(data.segmented.segmentedStack(1).data,2)-1) 1/(size(data.segmented.segmentedStack(1).data,2)-1)]);
        
        %Height
        slaideri(3) = uicontrol(esa,'style','slider','string','height','min',1,'max', size(data.segmented.segmentedStack(1).data,1)+0.99, ...
            'value',1,'callback',@setFig, ...
            'units','normalized','position',[0.2,0.09,0.6,0.03],'sliderstep',[1/(size(data.segmented.segmentedStack(1).data,1)-1) 1/(size(data.segmented.segmentedStack(1).data,1)-1)]);
        
        %Wait for the user to finish with the stack...
        
        notDone = 1;
        while notDone
           pause(1); 
        end

        
    end
    
    function filtered = timoMinFilt(dataIn,geometry)
        for d = 1:size(dataIn,3)
            for c = 1:size(dataIn,2)
                for r = 1:size(dataIn,1)
                    rLimits = checkLimits(r,size(dataIn,1),geometry(1));
                    cLimits = checkLimits(c,size(dataIn,2),geometry(2));
                    dLimits = checkLimits(d,size(dataIn,3),geometry(3));
                    filtered(r,c,d) = min(min(min(dataIn(rLimits,cLimits,dLimits))));
                end
            end
        end
        
    end
    function indices =  checkLimits(valIn,maxIn,width)
        diff = floor(width/2);
        indices = (valIn-diff):(valIn+diff);
        indices = indices(find(indices >= 1));
        indices = indices(find(indices <= maxIn));
    end

        function setFig(obj,evt)
    %          global data;
             sliceToShow = floor(get(obj,'Value'));
             string = get(obj,'string');

             if strcmp(string,'depth')
                 
                 set(lines(3),'xdata',[sliceToShow/19*250 sliceToShow/19*250]);
                 set(lines(5),'xdata',[sliceToShow/19*250 sliceToShow/19*250]);
                 
                 set(gcf,'currentaxes',f(1));
                 x1Data = get(lines(1),'xdata');
                 x2Data = get(lines(2),'xdata');
                 y1Data = get(lines(1),'ydata');
                 y2Data = get(lines(2),'ydata');
%                  hold off;
%                  imshow(mat2gray(squeeze(data3d(:,:,sliceToShow))),[]);
%                 hold on;
                set(imH(1),'CData',mat2gray(squeeze(minCoronal(:,:,sliceToShow))));
                set(lines(1),'xdata',x1Data,'ydata',y1Data);
                set(lines(2),'xdata',x2Data,'ydata',y2Data);
%                 lines(1) = plot(x1Data,y1Data,'b');
%                 lines(2) = plot(x2Data,y2Data,'r');
             end
             if strcmp(string,'width')
                   %Plot horizontal line to indicate where we are...
                 set(lines(1),'xdata',[sliceToShow sliceToShow]);
                 set(lines(6),'ydata',[sliceToShow sliceToShow]);
                 
                set(gcf,'currentaxes',f(2));
                x1Data = get(lines(3),'xdata');
                 x2Data = get(lines(4),'xdata');
                 y1Data = get(lines(3),'ydata');
                 y2Data = get(lines(4),'ydata');
%                  hold off;
%                  imshow(mat2gray(squeeze(data3d(:,sliceToShow,:))),[]);
%                 hold on;
%                 lines(3) = plot(x1Data,y1Data,'b');
%                 lines(4) = plot(x2Data,y2Data,'r');
                
                set(imH(2),'CData',mat2gray(squeeze(minSagittal(:,sliceToShow,:))));
                set(lines(3),'xdata',x1Data,'ydata',y1Data);
                set(lines(4),'xdata',x2Data,'ydata',y2Data);

%                 imshow(squeeze(data3d(:,sliceToShow,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,1)]);
%                 axis equal;
                
             end
            if strcmp(string,'height')
                
                set(lines(2),'ydata',[sliceToShow sliceToShow]);
                set(lines(4),'ydata',[sliceToShow sliceToShow]);
                set(gcf,'currentaxes',f(3));
                  x1Data = get(lines(5),'xdata');
                 x2Data = get(lines(6),'xdata');
                 y1Data = get(lines(5),'ydata');
                 y2Data = get(lines(6),'ydata');
%                 imshow(squeeze(data3d(sliceToShow,:,:)),[],'xdata',[1 250],'ydata',[1 size(data3d,2)]);
                set(imH(3),'CData',mat2gray(squeeze(minAxial(sliceToShow,:,:))));
                 set(lines(5),'xdata',x1Data,'ydata',y1Data);
                set(lines(6),'xdata',x2Data,'ydata',y2Data);
             end
             title(['Fig ' num2str(sliceToShow)]);
             drawnow;
        end

        function doneWithTheStack(obj,evt)
            notDone = 0;
            delete(esa);
        end
end