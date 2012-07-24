%Region growing function
%dataSlice contains the original 2D image data
%segmentationMask includes the seed points as 1 and other points as 0
%Will include new pixels until the diff of the lowest diff pixel increases
%to more than maxDiff.
function grown = growRegion(dataSlice,segmentationMask,maxDiff)
    global pixelQueue rowCount columnCount visited currentMean;
    if(exist('maxDiff','var')==0)
        maxDiff=250;    %Experimentally chosen for t1 SE DICOM
    end
    
    %Init algorithm
    rowCount = size(dataSlice,1);
    columnCount = size(dataSlice,2);
    matSize = size(dataSlice);
    visited = zeros(size(dataSlice,1),size(dataSlice,2),'uint8');
    seedIndices = find(segmentationMask > 0);
    pixelQueue = struct();
    currentMean = mean(dataSlice(seedIndices));
    %Add all seed points to pixel queue
    for i = 1:length(seedIndices)
        pixelQueue(i).cost = abs(dataSlice(seedIndices(i))-currentMean);
        [pixelQueue(i).coordinates(1) pixelQueue(i).coordinates(2)]= ind2sub(matSize,seedIndices(i));
    end
    
    while (exist('pixelQueue','var')> 0 && length(pixelQueue) > 0) %Go through all cells in queue
        [nextPixel pixelQueue] = pollQueue(pixelQueue);
        %Add 4-connected neighbourhood to the  queue, unless the
        %neighbourhood pixels have already been visited or are part of the
        %mask already
        %up one
        if nextPixel.cost <= maxDiff    %If cost is still less than maxDiff
            r = nextPixel.coordinates(1);
            c = nextPixel.coordinates(2);
            visited(r,c) = 1;
            segmentationMask(r,c) = 1;
            currentMean = mean(dataSlice(seedIndices));  %The mean needs to be updated to include the new pixel
            %Check 4-connected neigbour
            cR = [r-1 r+1 r r]; %Up down same same
            cC = [c c c+1 c-1]; %same same right left
            checkNeighbours(cR,cC);
        else %First pixel with higher than maxDiff cost
            clear pixelQueue;
        end
        
    end
    grown = segmentationMask;
    
    %%Function for checking the neighbour. Note that relevant matrices are
    %%defined in the parent function, so no need to put in matrices as parameters
    function checkNeighbours(cRs,cCs)
        for j = length(cRs)
            cR = cRs(j);
            cC = cCs(j);
            if cR >= 1 && cR <= rowCount && cC >=1 && cC <= columnCount %If the neigbour is within the image...
               if (visited(cR,cC) == 0 && segmentationMask(cR,cC) == 0)
                  indexTo = length(pixelQueue)+1;
                  pixelQueue(indexTo).cost = abs(dataSlice(cR,cC)-currentMean);
                  pixelQueue(indexTo).coordinates = [cR cC];
               end
            end
        end
    end
    
    %Peek queue function. Return the pixel with the lowest pixelCost and
    %remove it from queue. Note that relevant matrices are
    %%defined in the parent function, so no need to put in matrices as parameters
    function [nextPixel pixelQueue] = pollQueue(pixelQueue)
        disp(['pQue length ' num2str(length(pixelQueue))]);
        if length(pixelQueue) > 0
           [val ind] = sort([pixelQueue.cost]);
           nextPixel = pixelQueue(ind(1));
           pixelQueue(ind(1)) = []; %Remove the pixel from the queue
        else
            nextPixel = 0;
        end
    end
end