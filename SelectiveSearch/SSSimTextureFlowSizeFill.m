function [similarity indSim] = SSSimTextureFlowSizeFill(a, b, blobStruct)
% Texture + Flow + Size + Fill

indSim(:,1) = SSSimTexture(a, b, blobStruct);
indSIm(:,2) = SSSimFlow(a, b, blobStruct);
indSim(:,3) = SSSimSize(a, b, blobStruct);
indSim(:,4) = SSSimBoxFillOrig(a, b, blobStruct);

similarity = mean(indSim, 2);