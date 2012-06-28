addpath('U:\programming\AquaRehab\matlabLiveWire\MatlabLiveWire')
javaaddpath('U:\programming\AquaRehab\matlabLiveWire\MatlabLiveWire');
data = load(['Segmented' num2str(1) '.mat']);
%Original data
data3d = zeros(size(data.segmented.segmentedStack(1).data,1),size(data.segmented.segmentedStack(1).data,2),length(data.segmented.segmentedStack));
%Get 3D stack and fill voids
for s = 1:length(data.segmented.segmentedStack)
   data3d(:,:,s) =  data.segmented.segmentedStack(s).data;
end
global lineHandle returnedPath liveWireEngine imagePixels;
imagePixels = double(data3d(:,:,8));
    liveWireEngine = javaEngineLiveWire.LiveWireCosts(reshape(imagePixels',1,size(imagePixels,1)*size(imagePixels,2)),size(imagePixels,1),size(imagePixels,2));
%     liveWireEngine.setSeed(200,200);
%     returnedPath = liveWireEngine.returnPath(400, 400);
    imshow(mat2gray(imagePixels));
    hold on;
    set(gcf,'position',[10,10,1000,1000]);
    set(gcf,'WindowButtonUpFcn',@mouseLeftClick);  %%LiveWire init and setting points are handled with callbacks
    disp('Callback set');
    
    for s = 1:size(data3d,3)
        testikuva = double(data3d(:,:,10));
        testiFiltteri = [-1, -2, 0, 2, 1;
                         -2, -4, 0, 4, 2;
                         -1, -2, 0, 2, 1;
                         ];
         kulmaFiltteri = [-2,   -1, 0,  0,  0;
                         -1,    -4, -2, 0,  0;
                         0,    -2,  0,  2,  0;
                         0,     0,  2,  4,  1;
                         0,     0,  0,  1,  2;
                         ];
        testix = conv2(testikuva,testiFiltteri,'same');
        testiy = conv2(testikuva,testiFiltteri','same');
        testik = conv2(testikuva,kulmaFiltteri,'same');
        testik2 = conv2(testikuva,kulmaFiltteri','same');
        figure,imshow(sqrt(testix.^2+testiy.^2+testik.^2+testik2.^2),[])
        %Sobel filter kernels
        Gx = [-1,0,1;
              -2,0,2;
              -1, 0, 1;];
          %Y increases from top to bottom -> convolution kernel is flipped
          Gy = [1,2,1;
              0,0,0;
              -1, -2, -1;];
          gradientx = conv2(testikuva,Gx,'same');
          gradienty = conv2(testikuva,Gy,'same');
          
          gradientr = sqrt(gradientx.^2+gradienty.^2);
           figure,imshow(gradientr,[]);
          [xgrad,ygrad] = gradient(testikuva);
          rgrad = sqrt(xgrad.^2+ygrad.^2);
          figure,imshow(rgrad/max(max(rgrad)),[]);
          figure,imshow(gradientr/max(max(gradientr)),[]);
          addpath('LBP'); %Add LBP functions to path
          constants.lbpMapping=getmapping(16,'riu2');
          wholeImageLBP = lbp(testikuva,4,16,constants.lbpMapping,'matrix');
          figure,imshow(wholeImageLBP,[]);
          constants.binCutpoints = [203.265584365132,289.016577202241,366.310454646066,443.357000717588,523.854509353765,609.266961172952,704.389742210883,807.637243792730,925.894010147273,1064.78032237981,1236.73822169619,1457.33059878462,1760.15965964240,2231.98799250700,3206.62813383521;];
           wholeImageVarHist = cont(testikuva,4,16);
           wholeImageVarHist = wholeImageVarHist/max(max(wholeImageVarHist));
           wholeImageVarHist(find(wholeImageVarHist<0.01)) = 0;
          figure,imshow(wholeImageVarHist,[]);

           pause
      end
          fil = fspecial('laplacian');
          tuloskuva = imfilter(testikuva,fil);
          figure,imshow(tuloskuva,[]);
          
          zeroCrossings = zeros(size(tuloskuva,1),size(tuloskuva,2));
          for r = 1:size(tuloskuva,1)-1
              for c = 1:size(tuloskuva,2)-1
                  if sign(tuloskuva(r,c+1)) ~= sign(tuloskuva(r,c)) || sign(tuloskuva(r+1,c)) ~= sign(tuloskuva(r,c)) || sign(tuloskuva(r+1,c+1)) ~= sign(tuloskuva(r,c)) || tuloskuva(r,c) == 0
                    zeroCrossings(r,c) = 1;
                  end
              end
          end
          figure,imshow(zeroCrossings,[]);