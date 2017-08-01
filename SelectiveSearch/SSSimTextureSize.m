function [similarity indSim] = SSSimTextureSize(a, b, blobStruct)
% Texture + Size

indSim(:,1) = SSSimTexture(a, b, blobStruct);
indSim(:,2) = SSSimSize(a, b, blobStruct);

similarity = mean(indSim, 2);