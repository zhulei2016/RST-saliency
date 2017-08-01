function [similarity indSim] = SSSimBoxFillSize(a, b, blobStruct)
% Calculate similarity for a single edge.
% a is blob a. 
% b is blob b. 
% blobStruct is the list of blobStruct

indSim(:,1) = SSSimBoxFill(a, b, blobStruct);
indSim(:,2) = SSSimSize(a, b, blobStruct);


similarity = mean(indSim, 2);