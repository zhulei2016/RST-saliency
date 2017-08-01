function [boxes blobIndIm blobBoxes hierarchy priority] = VideoFrame2HierarchicalGrouping(colourIm, flowIm, segmentIm, sigma, k, minSize, colourType, functionHandles)
% function [boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping
%                              (im, sigma, k, minSize, colourType, functionHandles)
%
% Creates hierarchical grouping from a video frame. Is similar to
% Image2HierarchicalGrouping except that it takes also a flow field as
% extra input argument
%
% colourIm:             N x M x 3 colour image. Double in range [0,1]
% flowIm:               N x M x 2 flow image. Double in range [0,1]
% segmentIm:            N x M x 3 image to segment. UINT8 in range [0,255] (!)
% sigma (= 0.8):        Smoothing for initial segmentation (Felzenszwalb 2004)
% k (= 100):            Threshold for initial segmentation
% minSize (= 100):      Minimum size of segments for initial segmentation
% colourType:           ColourType in which to do grouping (see Image2ColourSpace)
% functionHandles:      Similarity functions which are called. Function
%                       creates as many hierarchies as there are functionHandles
%
% boxes:                N x 4 array with boxes of all hierarchical groupings
% blobIndIm:            Index image with the initial segmentation
% blobBoxes:            Boxes belonging to the indices in blobIndIm
% hierarchy:            M x 1 cell array with hierarchies. M =
%                       length(functionHandles)

% Get initial segmentation, boxes, and neighbouring blobs
[blobIndIm blobBoxes neighbours] = mexFelzenSegmentIndex(segmentIm, sigma, k, minSize);
numBlobs = size(blobBoxes,1);

% Skip hierarchical grouping if segmentation results in single region only
if numBlobs == 1
    warning('Oversegmentation results in a single region only');
    boxes = [1 1 size(colourIm,1) size(colourIm,2)];
    hierarchy = [];
    priority = 1;
    return;
end

%%% Calculate histograms and sizes as prerequisite for grouping procedure

% Get colour histogram
[colourHist blobSizes] = BlobStructColourHist(blobIndIm, colourIm);

% Get texture histogram
textureHist = BlobStructTextureHist(blobIndIm, colourIm);
% textureHist = BlobStructTextureHistLBP(blobIndIm, colourIm);

% Get flow histogram
minFlow = min(flowIm(:));
maxFlow = max(flowIm(:));
flowIm = (flowIm - minFlow) ./ (maxFlow - minFlow); % Range between 0-1
flowHist = BlobStructColourHist(blobIndIm, flowIm);

% Allocate memory for complete hierarchy.
blobStruct.colourHist = zeros(size(colourHist,2), numBlobs * 2 - 1);
blobStruct.textureHist = zeros(size(textureHist,2), numBlobs * 2 - 1);
blobStruct.flowHist = zeros(size(flowHist,2), numBlobs * 2 - 1);
blobStruct.size = zeros(numBlobs * 2 -1, 1);
blobStruct.boxes = zeros(numBlobs * 2 - 1, 4);

% Insert calculated histograms, sizes, and boxes
blobStruct.colourHist(:,1:numBlobs) = colourHist';
blobStruct.textureHist(:,1:numBlobs) = textureHist';
blobStruct.flowHist(:,1:numBlobs) = flowHist';
blobStruct.size(1:numBlobs) = blobSizes ./ 3;
blobStruct.boxes(1:numBlobs,:) = blobBoxes;

blobStruct.imSize = size(colourIm,1) * size(colourIm,2);

%%% If you want to use original blobs in similarity functions, uncomment
%%% these lines.
% blobStruct.blobs = cell(numBlobs * 2 - 1, 1);
% initialBlobs = SegmentIndices2Blobs(blobIndIm, blobBoxes);
% blobStruct.blobs(1:numBlobs) = initialBlobs;


% Loop over all merging strategies. Perform them one by one.
boxes = cell(1, length(functionHandles)+1);
priority = cell(1, length(functionHandles) + 1);
hierarchy = cell(1, length(functionHandles));
for i=1:length(functionHandles)
    [boxes{i} hierarchy{i} blobStructT mergeThreshold] = BlobStruct2HierarchicalGrouping(blobStruct, neighbours, numBlobs, functionHandles{i});
    boxes{i} = boxes{i}(numBlobs+1:end,:);
    priority{i} = (size(boxes{i}, 1):-1:1)';
end

% Also save the initial boxes
i = i+1;
boxes{i} = blobBoxes;
priority{i} = ones(size(boxes{i}, 1), 1) * (size(boxes{1}, 1)+1);

% Concatenate boxes and priorities resulting from the different merging
% strategies
boxes = cat(1, boxes{:});
priority = cat(1, priority{:});
[priority ids] = sort(priority, 'ascend');
boxes = boxes(ids,:);


