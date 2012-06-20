clear all;
close all;
clc;

addpath('LBP'); %Add LBP functions to path
lahde = 'karsittu\';

hakemistot = dir(lahde);
for i = 3:length(hakemistot)
    data = createTextureSamples([lahde hakemistot(i).name]);
end

% %tulos2(i).info.SpacingBetweenSlices    %3.6 mm
% %tulos2(i).info.PixelSpacing    %0,2734 mm

