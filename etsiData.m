function [tulos] = etsiData(juuri);
    tulos = struct();
    tulos = selaaHakemistot(juuri,tulos);
        
    %Go through a directory and its subfolders. If file is a folde re-run
    %this function, if a file run a function on it
    function [tulos] = selaaHakemistot(juuri, tulos)
       hakemistot = dir(juuri);
       for i = 3:length(hakemistot)
           if hakemistot(i).isdir   %Propagate into subfolder
               tulos = selaaHakemistot([juuri '\' hakemistot(i).name],tulos);
           else                     %Handle a regular file
                tulos = kasitteleTiedosto(juuri,hakemistot(i).name,tulos);
           end
           
       end
    end

    %Function for handling the files
    function tulos = kasitteleTiedosto(juuri,tiedosto,tulos)
        if length(fieldnames(tulos(length(tulos)))) < 1
            tulos(1).info = dicominfo([juuri '\' tiedosto]);
        else
            tulos(length(tulos)+1).info = dicominfo([juuri '\' tiedosto]);
        end
    end


    
end