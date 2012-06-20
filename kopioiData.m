function [tulos2] = kopioiData(tulos,kohde)
   loytyneita = 0;
   for i = 1:length(tulos)
       vali = strfind(cellstr(tulos(i).info.SeriesDescription),'t1');
      if ~isempty(vali{1})
          loytyneita = loytyneita + 1;
          tulos2(loytyneita).info = tulos(i).info;
          copyfile(tulos2(loytyneita).info.Filename,kohde);
      end
   end
end