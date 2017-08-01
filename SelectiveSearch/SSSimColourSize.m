function [similarity indSim] = SSSimColourSize(a, b, blobStruct)
% Colour + Size

indSim(:,1) = SSSimColour(a, b, blobStruct);
indSim(:,2) = SSSimSize(a, b, blobStruct);

similarity = mean(indSim, 2);