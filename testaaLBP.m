function data = testaaLBP(lahde)
    
    global data;
    addpath('LBP'); %Add LBP functions to path
    lahde = 'karsittu\kh3';

    dataTiedostot = dir(lahde);


     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
    filter = fspecial('gaussian',5,1);
    laplacianKernel = [0,1,0;1,-4,1;0,1,0];
%     lKernel = fspecial('laplacian');
    for i = 1:length(info)
       data(i).data = double(dicomread(info(jarjestys(i))));
       data(i).data = conv2(data(i).data,filter);
       data(i).edges = conv2(data(i).data,laplacianKernel);
       data(i).lbpData = cont(data(i).data,2,16,1:200:4000); 
       MAPPING=getmapping(16,'riu2');
       data(i).LBPHIST=lbp(data(i).data,2,16,MAPPING,'matrix');
    end
    esa = figure;
    sliceToShow = 1;
    i = 1;
    f(1) = subplot(2,2,i);
    i = i+1;
    imshow(data(sliceToShow).data,[]);
    f(i) = subplot(2,2,i);
    i = i+1;
    imshow(data(sliceToShow).edges,[]);
    f(i) = subplot(2,2,i);
    i = i+1;
    imshow(data(sliceToShow).lbpData,[]);
    f(i) = subplot(2,2,i);
    i = i+1;
     imshow(data(sliceToShow).LBPHIST,[]);
     title(['Fig ' num2str(1)]);
    set(esa,'position',[10 10 1200 1200],'visible','on');
    slaideri = uicontrol(esa,'style','slider','min',1,'max', length(info)+0.99, ...
        'value',1,'callback',@setFig, ...
        'units','normalized','position',[0.2,0.05,0.6,0.05],'sliderstep',[1/(length(info)-1) 1/(length(info)-1)]);
    
    function setFig(obj,evt)
%          global data;
         sliceToShow = floor(get(obj,'Value'));
         i = 1;
         set(gcf,'currentaxes',f(i));
         i = i+1;
         imshow(data(sliceToShow).data,[]);
          set(gcf,'currentaxes',f(i));
          i = i+1;
         imshow(data(sliceToShow).edges,[]);
         set(gcf,'currentaxes',f(i));
         i = i+1;
          imshow(data(sliceToShow).lbpData,[]);
           set(gcf,'currentaxes',f(i));
           i = i+1;
           imshow(data(sliceToShow).LBPHIST,[]);
           title(['Fig ' num2str(sliceToShow)]);
    end
end