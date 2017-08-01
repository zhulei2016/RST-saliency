function [similarity indSim] = SSSimColourTextureFlowSizeFillOrig(a, b, blobStruct)
% Colour + Texture + Flow + Size + Fill

indSim(:,1) = SSSimColour(a, b, blobStruct);
indSim(:,2) = SSSimTexture(a, b, blobStruct);
indSIm(:,3) = SSSimFlow(a, b, blobStruct);
indSim(:,4) = SSSimSize(a, b, blobStruct);
indSim(:,5) = SSSimBoxFillOrig(a, b, blobStruct);

similarity = mean(indSim, 2);