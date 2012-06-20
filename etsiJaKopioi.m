clear all;
close all;
clc;
juuri = 'Data\';
kohde = 'karsittu\kh';


hakemistot = dir(juuri);
for i = 3:length(hakemistot)
    tulos = etsiData([juuri hakemistot(i).name '\']);
    if isdir([kohde num2str(i-2)])
       disp(['Data exists!!! Nothgin done to ' kohde num2str(i-2)])
    else
        mkdir([kohde num2str(i-2)]);
        tulos2 = kopioiData(tulos,[kohde num2str(i-2)]);
    end
end

% %tulos2(i).info.SpacingBetweenSlices    %3.6 mm
% %tulos2(i).info.PixelSpacing    %0,2734 mm

