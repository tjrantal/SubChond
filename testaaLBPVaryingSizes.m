 function data = testaaLBP(lahde)
    
    global data notDone esa;
    addpath('LBP'); %Add LBP functions to path
    lahde = 'karsittu\kh3';
    constants.lbpSumHistogram = [0.0796223388743074,0.0243073782443861,0.0410979877515311,0.0481335666375036,0.0446121318168562,0.0407261592300962,0.0388305628463109,0.0399314668999708,0.0406240886555847,0.0398002333041703,0.0378025663458734,0.0407261592300962,0.0446777486147565,0.0476305045202683,0.0392898804316127,0.0247083697871099,0.0764654418197725,0.251013414989793;];
    lbpCutPoints = 0:17;
    dataTiedostot = dir(lahde);


     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
    filter = fspecial('gaussian');
    MAPPING=getmapping(16,'riu2');
    lbpBlockSize = 15;
    binCutpoints = [203.265584365132,289.016577202241,366.310454646066,443.357000717588,523.854509353765,609.266961172952,704.389742210883,807.637243792730,925.894010147273,1064.78032237981,1236.73822169619,1457.33059878462,1760.15965964240,2231.98799250700,3206.62813383521;];
    for i = 1:length(info)
       data(i).data = double(dicomread(info(jarjestys(i))));
       data(i).data = conv2(data(i).data,filter);
       data(i).lbp=lbp(data(i).data,2,16,MAPPING,'matrix');
        for r = 1:size(data(i).lbp,1)-lbpBlockSize
           for c = 1:size(data(i).lbp,2)-lbpBlockSize
               lbpHist = histc(reshape(data(i).lbp(r:r+lbpBlockSize,c:c+lbpBlockSize),1,(lbpBlockSize+1)^2),lbpCutPoints);
               lbpHist = lbpHist/sum(lbpHist);
               data(i).lCloseness(r,c) = checkClose(lbpHist,constants.lbpSumHistogram);
               if  data(i).lCloseness(r,c) > 0.8
                data(i).mask(r,c)=1;
               else
                data(i).mask(r,c)=0;
               end
           end
           
       end
       disp(['Done with file ' num2str(i) ' of ' num2str(length(info))]);
    end
    esa = figure;
    sliceToShow = 1;
    i = 1;
    f(1) = subplot(1,3,i);
    i = i+1;
    imshow(data(sliceToShow).data,[]);
    f(i) = subplot(1,3,i);
    i = i+1;
    imshow(data(sliceToShow).lbp,[]);
    f(i) = subplot(1,3,i);
    i = i+1;
     imshow(data(sliceToShow).mask,[]);
     title(['Fig ' num2str(1)]);
     notDone = 1;
    set(esa,'position',[10 10 1800 600],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
    slaideri = uicontrol(esa,'style','slider','min',1,'max', length(info)+0.99, ...
        'value',1,'callback',@setFig, ...
        'units','normalized','position',[0.2,0.05,0.6,0.05],'sliderstep',[1/(length(info)-1) 1/(length(info)-1)]);
    %Wait for the user to finish with the stack...
    while notDone
       pause(1); 
    end
    function setFig(obj,evt)
%          global data;
         sliceToShow = floor(get(obj,'Value'));
         i = 1;
         set(gcf,'currentaxes',f(i));
         i = i+1;
         imshow(data(sliceToShow).data,[]);
          set(gcf,'currentaxes',f(i));
          i = i+1;
          imshow(data(sliceToShow).lbp,[]);
           set(gcf,'currentaxes',f(i));
           i = i+1;
           imshow(data(sliceToShow).mask,[]);
           title(['Fig ' num2str(sliceToShow)]);
    end

    function doneWithTheStack(obj,evt)
        notDone = 0;
        delete(esa);
    end

    function closeness = checkClose(sampleHist,modelHist)
        closeness = 0;
        for h = 1:length(sampleHist)
            closeness = closeness + min([sampleHist(h) modelHist(h)]);
        end
    end
end