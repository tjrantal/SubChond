clear all;
close all;
clc;

addpath('LBP'); %Add LBP functions to path
lahde = 'karsittu\';

%Determined experimentally from texture samples
constants.lbpSumHistogram = [0.0796223388743074,0.0243073782443861,0.0410979877515311,0.0481335666375036,0.0446121318168562,0.0407261592300962,0.0388305628463109,0.0399314668999708,0.0406240886555847,0.0398002333041703,0.0378025663458734,0.0407261592300962,0.0446777486147565,0.0476305045202683,0.0392898804316127,0.0247083697871099,0.0764654418197725,0.251013414989793;];
constants.varianceSumHistogram = [0.0625036453776611,0.0625036453776611,0.0624963546223389,0.0625036453776611,0.0624963546223389,0.0624963546223389,0.0624963546223389,0.0625109361329834,0.0624963546223389,0.0624963546223389,0.0625036453776611,0.0624890638670166,0.0625109361329834,0.0624890638670166,0.0625109361329834,0.0624963546223389;];
hakemistot = dir(lahde);
samples = struct();
for i = 3:length(hakemistot)
%     data = createTextureSamples([lahde hakemistot(i).name]);
      
      samples(i-2).textureSample = extractTextureSamples([lahde hakemistot(i).name]);
      disp(['Extracted ' num2str(i-2) ' of ' num2str(length(hakemistot)-2)]);
end

lbpSumHistogram = lbpSumHistogram/(sum(lbpSumHistogram));
varianceSumHistogram = varianceSumHistogram/(sum(varianceSumHistogram));