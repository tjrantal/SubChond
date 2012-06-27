function segmentedStack = segmentStack3Dhisto(lahde,constants)


    dataTiedostot = dir(lahde);
    disp([lahde ' ' num2str(length(dataTiedostot))]);

     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
 
    segmentedStack = struct();
    tempStack = struct();
    lbpCutPoints = 0:17;
    varCutPoints = 0:15;
    lbpBlockSize = 9; %Use lbpBlockSize+1 x lbpBlockSize+1 sample for lbp
    
    for i = 1:length(info) %Go through the whole stack
       data = double(dicomread(info(jarjestys(i))));
       data = conv2(data,constants.filter);
       tempStack(i).data = data;
    end
    %Original data
    data3d = zeros(size(tempStack(1).data,1),size(tempStack(1).data,2),length(tempStack));
    grayHist3d = zeros(size(data3d,1)-lbpBlockSize,size(data3d,2)-lbpBlockSize,size(data3d,3));
    mask3d = zeros(size(data3d,1)-lbpBlockSize,size(data3d,2)-lbpBlockSize,size(data3d,3));
    %Get 3D stack and fill voids
    for s = 1:length(tempStack)
       data3d(:,:,s) =  tempStack(s).data;
    end
    clear tempStack;
%        wholeImageVarHist = cont(data,2,16,constants.binCutpoints);
%        wholeImageLBP = lbp(data,2,16,constants.lbpMapping,'matrix');


    for s = 2:(size(data3d,3)-1)
       for r = 1:size(data3d,1)-lbpBlockSize
           for c = 1:size(data3d,2)-lbpBlockSize

               grayHist = histc(reshape(data3d(r:r+lbpBlockSize,c:c+lbpBlockSize,(s-1):(s+1)),1,((lbpBlockSize+1)^2)*3),constants.gray3DBinCutpoints);
               grayHist = grayHist/sum(grayHist);
               grayHist3d(r,c,s) = checkClose(grayHist,constants.gray3DSumHistogram);
               if  grayHist3d(r,c,s) > 0.8
                mask3d(r,c,s)=1;
               else
                mask3d(r,c,s)=0;
               end
           end
%            disp(['Row ' num2str(r) '/' num2str(size(data,1)-lbpBlockSize) ' in file ' num2str(i-2)]);
       end
       disp(['segmented slice ' num2str(s) ' of ' num2str(size(data3d,3))]);
%        keyboard
    end
    segmentedStack.grayHist3d = grayHist3d;
    segmentedStack.data3d = data3d;
    segmentedStack.mask3d = mask3d;
    
    function closeness = checkClose(sampleHist,modelHist)
        closeness = 0;
        for h = 1:length(sampleHist)
            closeness = closeness + min([sampleHist(h) modelHist(h)]);
        end
    end
end