function data = createTextureSamples(lahde)
    
    global data notDone esa;


    dataTiedostot = dir(lahde);


     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
    filter = fspecial('gaussian',5,1);
    for i = 1:length(info)
       data(i).data = double(dicomread(info(jarjestys(i))));
       data(i).data = conv2(data(i).data,filter);
%        data(i).variance= cont(data(i).data,2,16,1:200:4000); 
%        MAPPING=getmapping(16,'riu2');
%        data(i).lbp=lbp(data(i).data,2,16,MAPPING,'matrix');
       data(i).data(350:380,170:300) = data(i).data(350:380,170:300)+300;
    end
    esa = figure;
    sliceToShow = 9;
    i = 1;
    f(1) = subplot(1,1,i);
    i = i+1;
        imshow(data(sliceToShow).data,[]);
%     f(i) = subplot(1,3,i);
%     i = i+1;
%     imshow(data(sliceToShow).variance,[]);
%     f(i) = subplot(1,3,i);
%     i = i+1;
%      imshow(data(sliceToShow).lbp,[]);
     title(['Fig ' num2str(sliceToShow)]);
     notDone = 1;
    set(esa,'position',[10 10 600 600],'visible','on','CloseRequestFcn',@doneWithTheStack);    %Wait for the work to be done
    slaideri = uicontrol(esa,'style','slider','min',1,'max', length(info)+0.99, ...
        'value',sliceToShow,'callback',@setFig, ...
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
%           set(gcf,'currentaxes',f(i));
%           i = i+1;
%           imshow(data(sliceToShow).variance,[]);
%            set(gcf,'currentaxes',f(i));
%            i = i+1;
%            imshow(data(sliceToShow).lbp,[]);
           title(['Fig ' num2str(sliceToShow)]);
    end

    function doneWithTheStack(obj,evt)
        notDone = 0;
        delete(esa);
    end
end