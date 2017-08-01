function [similarity indSim] = SSSimTextureSizeFill(a, b, blobStruct)
% Texture + Size + Fill

indSim(:,1) = SSSimTexture(a, b, blobStruct);
indSim(:,2) = SSSimSize(a, b, blobStruct);
indSim(:,3) = SSSimBoxFillOrig(a, b, blobStruct);

similarity = mean(indSim, 2);