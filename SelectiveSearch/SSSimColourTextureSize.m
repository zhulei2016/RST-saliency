function [similarity indSim] = SSSimColourTextureSize(a, b, blobStruct)
% Colour + Texture + Size

indSim(:,1) = SSSimColour(a, b, blobStruct);
indSim(:,2) = SSSimTexture(a, b, blobStruct);
indSim(:,3) = SSSimSize(a, b, blobStruct);

similarity = mean(indSim, 2);