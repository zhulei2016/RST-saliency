function [similarity indSim] = SSSimBoxFillOrig(a, b, blobStruct)
% Calculate similarity for a single edge.
% a is blob a. 
% b is blob b. 
% blobStruct is the list of blobStruct

newArea = (max(blobStruct.boxes(a,3), blobStruct.boxes(b,3)) - ...
           min(blobStruct.boxes(a,1), blobStruct.boxes(b,1)) + 1) .* ...
          (max(blobStruct.boxes(a,4), blobStruct.boxes(b,4)) - ...
           min(blobStruct.boxes(a,2), blobStruct.boxes(b,2)) + 1);
distance = (newArea - blobStruct.size(a) - blobStruct.size(b)) ./ blobStruct.imSize;
similarity = (1 - distance);

indSim = similarity;