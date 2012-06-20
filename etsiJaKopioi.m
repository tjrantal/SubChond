close all;
clear all;
clc;
% juuri = 'Data';
% kohde = 'karsittu\kh1';
% juuri = 'Data\11013012\';
% kohde = 'karsittu\kh2';
juuri = 'Data\10070519\';
kohde = 'karsittu\kh3';


tulos = etsiData(juuri);
tulos2 = kopioiData(tulos,kohde);

% for i = 1:length(tulos2)
%    temp(i).SliceLocation = tulos2(i).info.SliceLocation;
% end
% [values,jarjestys] = sort([temp().SliceLocation]);
% esa = figure;
% for i = 1:length(tulos2)
%    %tulos2(i).info.Width
% %    [num2str(i) tulos2(i).info.SequenceName]
% %    [num2str(i) ' ' tulos2(i).info.ProtocolName]
% %    [num2str(i) ' ' tulos2(i).info.Private_0019_1008]
% %    [num2str(i) ' ' num2str(tulos2(i).info.SeriesNumber)]
% %    [num2str(i) ' ' num2str(tulos2(i).info.AcquisitionNumber)]
% %     [num2str(i) ' ' num2str(tulos2(i).info.SliceLocation)]
%    
%    data = dicomread(tulos2(jarjestys(i)).info);
%    imshow(mat2gray(data))
%    drawnow;
%     pause(0.5);
% end
% 
% %tulos2(i).info.SpacingBetweenSlices    %3.6 mm
% %tulos2(i).info.PixelSpacing    %0,2734 mm