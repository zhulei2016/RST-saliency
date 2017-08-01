function [boxes, hierarchy, blobStruct, mergeThresholds] = ...
    BlobStruct2HierarchicalGrouping(blobStruct, neighbourMat, numInitBlobs, CalculateSimilarity)
% [boxes hierarchy blobStruct mergeThresholds] = BlobStruct2HierarchicalGrouping
%                      (blobStruct, neighbourMat, numInitBlobs, CalculateSimilarity)
%
% Groups adjacent regions together greedily using the CalculateSimilarity
% function
%
% blobStruct:               Structure with the folowing elements, where N is the
%                       number of blobs of the whole hierarchical grouping, 
%                       calculated as the number of initial blobs x 2 - 1,
%                       where only the first elements of the initial
%                       segmentation should contain proper values, whereas the
%                       rest should be preallocated for memory. 
%   .size:              Nx1 vector with sizes.
%   .boxes:             Nx4 vector denoting the rectangle for each blob
%   .colourHist:        NxU vector with histograms for each N blobs
%   .textureHist:       NxV vector with histograms for each N blobs
% neighbourMat:         Matrix containing neighbours of blobs, as returned
%                       by mexFelzenSegmentIndex
% numInitBlobs:         The number of initial blobs
% CalculateSimilarity:  Function handle to the used similarity
%
% boxes:                Boxes of all the segments in the hierarchy
% hierarchy:            Denotes the hierarchy
% blobStruct:                Same structure as above, now filled completely.
% mergeThresholds:      Values for the merging


% Only need the lower half.
neighbourMat = tril(neighbourMat,-1);

% simsB = cell(1, size(neighbourMat,2));
% for i=1:size(neighbourMat, 2)
%     neighbourInd = find(neighbourMat(:,i));
%     if ~isempty(neighbourInd)
%         simsB{i} = CalculateSimilarity(find(neighbourMat(:,i)), i, blobStruct);
%     end
% end

[nb, na] = find(neighbourMat == 1);
similarities = CalculateSimilarity(nb, na, blobStruct);

% similarities = cat(1, simsB{:});


%%%%% BEGIN MERGING ALGORITHM %%%%%%

% Get new blobId.
newBlobId = numInitBlobs + 1;

% display('Begin hierarchical merge');
mergeThresholds = ones(length(blobStruct.size), 1);

% Begin the hierarchical merge loop
while(size(na,1) > 1)
    % Sort the similarities in ascending order. This means the last
    % element has to be merged.
    [similarities, idx] = sort(similarities);
    
    na = na(idx);
    nb = nb(idx);
    
    % Get last entry and remove from [na nb similarities]
    a = na(end);
    b = nb(end);
    na = na(1:end-1);
    nb = nb(1:end-1);
    currSimilarity = similarities(end);
    similarities = similarities(1:end-1);
    
    % Merge last (and thus most similar) entry
    blobStruct = MergeBlobStructure(blobStruct, a, b, newBlobId);
    %%%%Made function inline for speed.
%     sizeA = blobStruct.size(a);
%     sizeB = blobStruct.size(b);
%     sizeC = sizeA + sizeB;
% 
%     blobStruct.size(newBlobId) = sizeC;
%     
%     % blobStruct.boxes(newBlobId,:) = BoxUnion(blobStruct.boxes(a,:), blobStruct.boxes(b,:));
%     % Do BoxUnion inline for speed
%     blobStruct.boxes(newBlobId,:) = [min(blobStruct.boxes(a,1), blobStruct.boxes(b,1)) ...
%                                 min(blobStruct.boxes(a,2), blobStruct.boxes(b,2)) ...
%                                 max(blobStruct.boxes(a,3), blobStruct.boxes(b,3)) ...
%                                 max(blobStruct.boxes(a,4), blobStruct.boxes(b,4))];
% 
%     if isfield(blobStruct, 'colourHist')
%         blobStruct.colourHist(:,newBlobId) = (sizeA .* blobStruct.colourHist(:,a) + ...
%                                  sizeB .* blobStruct.colourHist(:,b)) ./ sizeC;
%     end
% 
%     if isfield(blobStruct, 'textureHist')
%         blobStruct.textureHist(:,newBlobId) = (sizeA .* blobStruct.textureHist(:,a) + ...
%                                   sizeB .* blobStruct.textureHist(:,b)) ./ sizeC;
%     end
%     
%     if isfield(blobStruct, 'blobs')
%         blobStruct.blobs{newBlobId} = MergeBlobs(blobStruct.blobs{a}, blobStruct.blobs{b});
%     end
    %%%% END MergeBlobStructure
    
    % Get indices where a and b need to be replaced
    edges = [na nb];
    [ar,ac] = find(edges == a);
    [br,bc] = find(edges == b);
    R = [ar;br];
    C = [ac;bc];
    
    % Remove old edges and similarities
    oldEdges = edges(R,:);
    edges(R,:) = [];
    similarities(R,:) = [];
    
    % Get neighbours
    C = mod(C,2); % 1->1, 2->0
    lengthC = length(C);
    neighbours = oldEdges((1:lengthC) + (C' .* lengthC));
    
    % Remove duplicates (using code from 'unique')
    neighbours = sort(neighbours);
    diffNeighbours = [diff(neighbours) 1];
    neighbours = neighbours(diffNeighbours ~= 0);

    newEdges = zeros(length(neighbours), 2);
    newEdges(:,2) = neighbours;
    newEdges(:,1) = newBlobId;
    
    % newEdges and edges together form the new list. Separate again in
    % [na,nb]
    edges = [edges;newEdges];
    na = edges(:,1);
    nb = edges(:,2);
    
    % Get new similarities and add them to the old similarities.
    newSims = CalculateSimilarity(newEdges(:,2), newEdges(1,1), blobStruct); % all second edges are the same
    
    hierarchy(a) = newBlobId;
    hierarchy(b) = newBlobId;
    mergeThresholds(newBlobId) = currSimilarity;
    similarities = [similarities; newSims];  
    newBlobId = newBlobId + 1;

end

% Now there is only one merge left to do. The final one.
a = na(1);
b = nb(1);
blobStruct = MergeBlobStructure(blobStruct, a, b, newBlobId);

mergeThresholds(newBlobId) = 0;
hierarchy(a) = newBlobId;
hierarchy(b) = newBlobId;

boxes = blobStruct.boxes;


%%% Made function inline for speed (except for very end)
function blobStruct = MergeBlobStructure(blobStruct, a, b, c)
% Merges the measurements of blob a and b into blob c

sizeA = blobStruct.size(a);
sizeB = blobStruct.size(b);
sizeC = sizeA + sizeB;

blobStruct.size(c) = sizeC;
blobStruct.boxes(c,:) = BoxUnion(blobStruct.boxes(a,:), blobStruct.boxes(b,:));

if isfield(blobStruct, 'colourHist')
    blobStruct.colourHist(:,c) = (sizeA .* blobStruct.colourHist(:,a) + ...
                             sizeB .* blobStruct.colourHist(:,b)) ./ sizeC;
end
    
if isfield(blobStruct, 'textureHist')
    blobStruct.textureHist(:,c) = (sizeA .* blobStruct.textureHist(:,a) + ...
                              sizeB .* blobStruct.textureHist(:,b)) ./ sizeC;
end

if isfield(blobStruct, 'flowHist')
        blobStruct.flowHist(:,c) = (sizeA .* blobStruct.flowHist(:,a) + ...
                              sizeB .* blobStruct.flowHist(:,b)) ./ sizeC;
end

if isfield(blobStruct, 'blobs')
    blobStruct.blobs{c} = MergeBlobs(blobStruct.blobs{a}, blobStruct.blobs{b});
end

