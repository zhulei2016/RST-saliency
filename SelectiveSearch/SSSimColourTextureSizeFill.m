function [similarity indSim] = SSSimColourTextureSizeFill(a, b, blobStruct)
% Colour + Texture + Size + Fill

indSim(:,1) = SSSimColour(a, b, blobStruct);
indSim(:,2) = SSSimTexture(a, b, blobStruct);
indSim(:,3) = SSSimSize(a, b, blobStruct);
indSim(:,4) = SSSimBoxFill(a, b, blobStruct);

similarity = mean(indSim, 2);