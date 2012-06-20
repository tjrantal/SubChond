clear all;
close all;
clc;

addpath('LBP'); %Add LBP functions to path
lahde = 'karsittu\';

hakemistot = dir(lahde);
samples = struct();
for i = 3:length(hakemistot)
%     data = createTextureSamples([lahde hakemistot(i).name]);
      
      samples(i-2).textureSample = extractTextureSamples([lahde hakemistot(i).name]);
      disp(['Extracted ' num2str(i-2) ' of ' num2str(length(hakemistot)-2)]);
end
save('samples.mat','samples');

%Visualize samples
esa = figure;
set(gcf,'position',[10 10 1200 500]);
i = 1;
for i = 1:3
    f(i) = subplot(1,3,i);
end
for s = 1:length(samples)
    for t = 1:length(samples(s).textureSample)
         set(esa,'currentaxes',f(1));
         imshow(samples(s).textureSample(t).data,[]);
         set(esa,'currentaxes',f(2));
         plot(samples(s).textureSample(t).varianceHist,'r');
         set(esa,'currentaxes',f(3));
         plot(samples(s).textureSample(t).lbpHist,'r');
         drawnow
         pause(0.5)
    end
end
close(esa);

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

%Calculate mean histograms for local variance and for LBP
lbpSumHistogram = zeros(1,18);
varianceSumHistogram = zeros(1,16);

for s = 1:length(samples)
    for t = 1:length(samples(s).textureSample)
        lbpSumHistogram = lbpSumHistogram+samples(s).textureSample(t).lbpHist;
        varianceSumHistogram = varianceSumHistogram+samples(s).textureSample(t).varianceHist;
    end
end

lbpSumHistogram = lbpSumHistogram/(sum(lbpSumHistogram));
varianceSumHistogram = varianceSumHistogram/(sum(varianceSumHistogram));