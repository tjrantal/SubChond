%%Requires javaLoop\JavaLoop.java java class
%%Compile: javac javaLoop\JavaLoop.java

function segmentedStack = segmentStack(lahde,constants)


    dataTiedostot = dir(lahde);


     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
 
    segmentedStack = struct();
    lbpCutPoints = 0:17;
    varCutPoints = 0:15;
    lbpBlockSize = 15; %Use lbpBlockSize+1 x lbpBlockSize+1 sample for lbp
    for i = 1:length(info) %Go through the whole stack
       segmentedStack(i).info = info(jarjestys(i));
       data = double(dicomread(info(jarjestys(i))));
       data = conv2(data,constants.filter);
       segmentedStack(i).data = data;
       wholeImageVarHist = cont(data,2,16,constants.binCutpoints);
       wholeImageLBP = lbp(data,2,16,constants.lbpMapping,'matrix');
       disp('Into javaLoop');
       javaSpeedUp = javaLoop.JavaLoop(wholeImageVarHist, wholeImageLBP, data, varCutPoints, lbpCutPoints, constants.grayBinCutpoints, ...
           lbpBlockSize, constants.varianceSumHistogram,constants.lbpSumHistogram,constants.graySumHistogram);
%        r = 1;
%        c = 1;
%         dblock = reshape(wholeImageVarHist(r:r+lbpBlockSize,c:c+lbpBlockSize),1,(lbpBlockSize+1)^2);
%         varHist = histc(dblock,varCutPoints);
       %        histograms2 = zeros(size(wholeImageVarHist,1)-lbpBlockSize,size(wholeImageVarHist,2)-lbpBlockSize,16);
%        for r = 1:size(wholeImageVarHist,1)-lbpBlockSize
%            for c = 1:size(wholeImageVarHist,2)-lbpBlockSize
%                varHist = histc(reshape(wholeImageVarHist(r:r+lbpBlockSize,c:c+lbpBlockSize),1,(lbpBlockSize+1)^2),varCutPoints);
%                lbpHist = histc(reshape(wholeImageLBP(r:r+lbpBlockSize,c:c+lbpBlockSize),1,(lbpBlockSize+1)^2),lbpCutPoints);

%                grayHist = histc(reshape(data(r:r+lbpBlockSize,c:c+lbpBlockSize),1,(lbpBlockSize+1)^2),constants.grayBinCutpoints);
%                varHist = varHist/sum(varHist);
%                lbpHist = lbpHist/sum(lbpHist);
%                grayHist = grayHist/sum(grayHist);
%                histograms2(r,c,:) = varHist;
% %                segmentedStack(i).varianceHist(r,c,:)= varHist;
% %                segmentedStack(i).lbpHist(r,c,:)= lbpHist;
% %                segmentedStack(i).grayHist(r,c,:)= grayHist;
% %                segmentedStack(i).vCloseness(r,c) = checkClose(varHist,constants.varianceSumHistogram);
% %                segmentedStack(i).lCloseness(r,c) = checkClose(lbpHist,constants.lbpSumHistogram);
% %                segmentedStack(i).gCloseness(r,c) = checkClose(grayHist,constants.graySumHistogram);
%                 segmentedStack2(i).vCloseness(r,c) = checkClose(varHist,constants.varianceSumHistogram);
%                segmentedStack2(i).lCloseness(r,c) = checkClose(lbpHist,constants.lbpSumHistogram);
%                segmentedStack2(i).gCloseness(r,c) = checkClose(grayHist,constants.graySumHistogram);
%                 %figure,imshow(segmentedStack2(i).lCloseness)
% %                if  segmentedStack(i).vCloseness(r,c)+segmentedStack(i).lCloseness(r,c)+segmentedStack(i).gCloseness(r,c) > 1.9
% %                 segmentedStack(i).mask(r,c)=1;
% %                else
% %                 segmentedStack(i).mask(r,c)=0;
% %                end
%            end
%            disp(['Row ' num2str(r) '/' num2str(size(data,1)-lbpBlockSize) ' in file ' num2str(i)]);
%        end
        segmentedStack(i).vCloseness = javaSpeedUp.vCloseness;
        segmentedStack(i).lCloseness = javaSpeedUp.lCloseness;
%         figure,imshow(segmentedStack(i).lCloseness)
        segmentedStack(i).gCloseness = javaSpeedUp.gCloseness;
       segmentedStack(i).mask = javaSpeedUp.mask;
%        keyboard;
       clear javaSpeedUp;
       disp(['segmented file ' num2str(i)]);
    end
    
    function closeness = checkClose(sampleHist,modelHist)
        closeness = 0;
        for h = 1:length(sampleHist)
            closeness = closeness + min([sampleHist(h) modelHist(h)]);
        end
    end
end