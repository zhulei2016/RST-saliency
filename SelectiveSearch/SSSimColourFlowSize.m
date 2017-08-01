function [similarity indSim] = SSSimColourFlowSize(a, b, blobStruct)
% Colour + Flow + Size

indSim(:,1) = SSSimColour(a, b, blobStruct);
indSim(:,2) = SSSimFlow(a, b, blobStruct);
indSim(:,3) = SSSimSize(a, b, blobStruct);

similarity = mean(indSim, 2);