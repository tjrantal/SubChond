clear all;
close all;
clc;

data = load('samples.mat');
% Visualize samples
% esa = figure;
% set(gcf,'position',[10 10 1200 500]);
% i = 1;
% for i = 1:3
%     f(i) = subplot(1,3,i);
% end
% for s = 1:length(data.samples)
%     for t = 1:length(data.samples(s).textureSample)
%          set(esa,'currentaxes',f(1));
%          imshow(data.samples(s).textureSample(t).data,[]);
%          set(esa,'currentaxes',f(2));
%          plot(data.samples(s).textureSample(t).varianceHist,'r');
%          set(esa,'currentaxes',f(3));
%          plot(data.samples(s).textureSample(t).lbpHist,'r');
%          drawnow
%          pause
%     end
% end
% close(esa);

%Create 3D histograms
sampleGray3d = zeros(size(data.samples(1).textureSample(1).data,1),size(data.samples(1).textureSample(1).data,2),length(data.samples(1).textureSample),length(data.samples));
for s = 1:length(data.samples)
    for t = 1:length(data.samples(s).textureSample)
         sampleGray3d(:,:,t,s) = data.samples(s).textureSample(t).data;
    end
end

allGrayHistSamples = sampleGray3d(:);
allGrayHistSamples = sort(allGrayHistSamples);
B = 16;
grayBinIndices = round(linspace(1,length(allGrayHistSamples),B+1));
gray3DBinCutpoints = allGrayHistSamples(grayBinIndices(2:B));
gray3DBinCutpoints = [-inf; gray3DBinCutpoints; inf]';
histogrammi = histc(sampleGray3d(:),gray3DBinCutpoints);
histogrammi = histogrammi/sum(histogrammi);
histogrammi = histogrammi';
plot(histogrammi)
% %Calculate histogram bins for local variance
% allVarianceSamples = [];
% for s = 1:length(samples)
%     for t = 1:length(samples(s).textureSample)
%          allVarianceSamples = [allVarianceSamples reshape(samples(s).textureSample(t).variance,1,size(samples(s).textureSample(t).variance,1)*size(samples(s).textureSample(t).variance,2))];
%     end
% end
% plot(allVarianceSamples)
% allVarianceSamples = sort(allVarianceSamples);
% B = 16;
% binIndices = round(linspace(1,length(allVarianceSamples),B+1))
% binCutpoints = allVarianceSamples(binIndices(2:16));
% test = hist(allVarianceSamples,binCutpoints)
% plot(test)

% %Calculate mean histograms for local variance and for LBP
% lbpSumHistogram = zeros(1,18);
% varianceSumHistogram = zeros(1,16);
% graySumHistogram = zeros(1,17);
% 
% for s = 1:length(samples)
%     for t = 1:length(samples(s).textureSample)
%         lbpSumHistogram = lbpSumHistogram+samples(s).textureSample(t).lbpHist;
%         varianceSumHistogram = varianceSumHistogram+samples(s).textureSample(t).varianceHist;
%         graySumHistogram = graySumHistogram+samples(s).textureSample(t).grayHist';
%     end
% end
% 
% lbpSumHistogram = lbpSumHistogram/(sum(lbpSumHistogram));
% varianceSumHistogram = varianceSumHistogram/(sum(varianceSumHistogram));
% graySumHistogram = graySumHistogram/sum(graySumHistogram);