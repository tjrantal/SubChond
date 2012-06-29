clear all;
close all;
clc;

addpath('LBP'); %Add LBP functions to path
javaaddpath('.');
lahde = 'karsittu\';

constants.filter = fspecial('gaussian');
constants.lbpMapping=getmapping(16,'riu2');
%Determined experimentally from texture samples
constants.binCutpoints = [203.265584365132,289.016577202241,366.310454646066,443.357000717588,523.854509353765,609.266961172952,704.389742210883,807.637243792730,925.894010147273,1064.78032237981,1236.73822169619,1457.33059878462,1760.15965964240,2231.98799250700,3206.62813383521;];
constants.grayBinCutpoints = [-inf 500:50:1200 inf];
constants.lbpSumHistogram = [0.0796223388743074,0.0243073782443861,0.0410979877515311,0.0481335666375036,0.0446121318168562,0.0407261592300962,0.0388305628463109,0.0399314668999708,0.0406240886555847,0.0398002333041703,0.0378025663458734,0.0407261592300962,0.0446777486147565,0.0476305045202683,0.0392898804316127,0.0247083697871099,0.0764654418197725,0.251013414989793;];
constants.varianceSumHistogram = [0.0625036453776611,0.0625036453776611,0.0624963546223389,0.0625036453776611,0.0624963546223389,0.0624963546223389,0.0624963546223389,0.0625109361329834,0.0624963546223389,0.0624963546223389,0.0625036453776611,0.0624890638670166,0.0625109361329834,0.0624890638670166,0.0625109361329834,0.0624963546223389;];
constants.graySumHistogram = [0.000480177296232455,0.000147746860379217,0.000160059098744152,0.000437084461955183,0.00128047278995321,0.00589756217680374,0.0233624722974637,0.0717865057867520,0.125640236394977,0.165488795863088,0.188247968480670,0.180072642206353,0.135680866781581,0.0679881802511697,0.0259911351883772,0.00733809406550111,0;];
constants.min3DBinCutpoints = [-Inf,769.257286526609,803.350720607429,826.527964293588,846.941552155667,866.880889655944,884.930208419108,900.838664590984,916.491258796024,932.593509676166,949.486375913169,967.054195585596,985.951475172491,1005.73814287238,1027.80999185755,1060.07735865210,Inf;];
constants.minSumHistogram = [0.0624353607485841,0.0624907658212263,0.0625215464171386,0.0624722974636789,0.0625707953705984,0.0624661413444964,0.0625092341787737,0.0625338586555036,0.0624538291061315,0.0625092341787737,0.0625338586555036,0.0624415168677666,0.0625338586555036,0.0624415168677666,0.0625769514897809,0.0625092341787737,0;];
hakemistot = dir(lahde);
samples = struct();
for i = 3%:length(hakemistot)
        %T�h�n funktio, jolla segmentointi l�hdet��n tekem��n!!!
        %Tee ensiksi esim. 16 x 16 neighborhoodeilla
        %Laske koko kuvalle LBP-arvot ja var -arvot -> tee histogrammit
        %itse, jotta ei lasketa pikseleit� satoja kertoja?
        %Kokeile ensin kuitenkin vain sy�tt�� 16x16 blokkeja ilman 
        %laskennassa s��st�mist�...
        %Voisi my�s kokeilla ympyr�blokkeja?
%     data = createTextureSamples([lahde hakemistot(i).name]);
    segmented = struct();
    segmented.segmentedStack = segmentStackMin([lahde hakemistot(i).name],constants);
    save(['SegmentedMin' num2str(i-2) '.mat'],'segmented'); %Save the results as we go in order to not lose all of the data done...
    disp(['Segmented ' num2str(i-2) ' of ' num2str(length(hakemistot)-2)]);
%     keyboard;
end


