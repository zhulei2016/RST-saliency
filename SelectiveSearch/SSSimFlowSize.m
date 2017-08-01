function [similarity indSim] = SSSimFlowSize(a, b, blobStruct)
% Flow + Size

indSim(:,1) = SSSimFlow(a, b, blobStruct);
indSim(:,2) = SSSimSize(a, b, blobStruct);

similarity = mean(indSim, 2);