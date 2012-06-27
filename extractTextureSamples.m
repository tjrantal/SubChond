function textureSamples = extractTextureSamples(lahde)
    

    dataTiedostot = dir(lahde);


     for i = 3:length(dataTiedostot)
         info(i-2) = dicominfo([lahde '\' dataTiedostot(i).name]);

     end
    [values,jarjestys] = sort([info().SliceLocation]);
  
    filter = fspecial('gaussian');
    lbpMapping=getmapping(16,'riu2');
    textureSamples = struct();
    %Update the cutpoints after acquiring samples
    binCutpoints = [203.265584365132,289.016577202241,366.310454646066,443.357000717588,523.854509353765,609.266961172952,704.389742210883,807.637243792730,925.894010147273,1064.78032237981,1236.73822169619,1457.33059878462,1760.15965964240,2231.98799250700,3206.62813383521;];
    grayBinCutpoints = [-inf 500:50:1200 inf];
    for i = 9:12 %slices 9 to 16 were manually selected..
       data = double(dicomread(info(jarjestys(i))));
       data = conv2(data,filter);
       data = data(350:380,170:300);
       textureSamples(i-8).data = data;
       textureSamples(i-8).varianceHist= cont(data,2,16,binCutpoints,'h');
       textureSamples(i-8).lbpHist=lbp(data,2,16,lbpMapping,'h');
       textureSamples(i-8).grayHist=histc(data(:),grayBinCutpoints);
    end
end