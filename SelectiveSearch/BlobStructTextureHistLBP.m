function textureHist = BlobStructTextureHistLBP(blobIndIm, colourIm)

% Get LBP's for all colour channels
textureHistT = cell(1, size(colourIm,3));
numBlobs = max(blobIndIm(:));

% for i=1:size(colourIm,3)
%     currIm = GaussFilter(colourIm(:,:,i), 'smooth', .3);
% %     currIm = colourIm(:,:,i);
%     [LBP numBins] = Image2LBPPlus(currIm);
%     
%     textureHistT{i} = CountVisualWordsIndex(blobIndIm, LBP, numBlobs, numBins);
% end
% 
% % Concatenate histograms for each color channel
% textureHist = cat(2, textureHistT{:});
% textureHist = NormalizeRows(textureHist);



for i=1:size(colourIm,3)
    currIm(:,:,i) = GaussFilter(colourIm(:,:,i), 'smooth', 0.3);
end
[LBP numBins] = Image2LBP3D(currIm);
textureHist = CountVisualWordsIndex(blobIndIm, LBP, numBlobs, numBins);
goodI = sum(textureHist) > 0;
textureHist = NormalizeRows(textureHist(:,goodI));

