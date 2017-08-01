function blob = MergeBlobs(A, B)
% blob = MergeBlobs(A, B)
%
% MergeBlobs merges two blobs A and B.

% Construct rectangle.
blob.rect = [min(A.rect(1), B.rect(1)), min(A.rect(2), B.rect(2)), ...
             max(A.rect(3), B.rect(3)), max(A.rect(4), B.rect(4))];

if isfield(A, 'mask')
    % Create zero mask. Notice the +1 that is necessary because array starts
    % with 1.
    blob.mask = zeros(blob.rect(3) - blob.rect(1) + 1, blob.rect(4) - blob.rect(2) + 1);

    % Copy the mask of A into blob.
    blob.mask(A.rect(1) - blob.rect(1)+1:A.rect(3) - blob.rect(1)+1, ...
               A.rect(2) - blob.rect(2)+1:A.rect(4) - blob.rect(2)+1) = A.mask;

    % Now we can not just copy. Instead use the and operator, which is equal to
    % the max operator in thie case.
    blob.mask(B.rect(1) - blob.rect(1)+1:B.rect(3) - blob.rect(1)+1, ...
               B.rect(2) - blob.rect(2)+1:B.rect(4) - blob.rect(2)+1) = ...
               max( blob.mask(B.rect(1) - blob.rect(1)+1:B.rect(3) - blob.rect(1)+1, ...
                     B.rect(2) - blob.rect(2)+1:B.rect(4) - blob.rect(2)+1), ...
                      B.mask);

    % Convert to boolean.
    blob.mask = logical(blob.mask);
end
    
% For non-overlapping regions, we can update the size
if isfield(A, 'size')
    blob.size = A.size + B.size;
end

% For non-overlapping regions, we can update the histograms
if isfield(A, 'colourHist')
    blob.colourHist = ((A.size .* A.colourHist) + (B.size .* B.colourHist)) / blob.size;
end

if isfield(A, 'textureHist')
    blob.textureHist = ((A.size .* A.textureHist) + (B.size .* B.textureHist)) / blob.size;
end

% Add borderSize if the field exists i blob
if isfield(A, 'borderSize')
    blob.borderSize = CalculateBorderSize(blob);
end
