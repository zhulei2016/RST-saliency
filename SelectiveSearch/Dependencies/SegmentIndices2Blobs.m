function [blobs, na, nb] = SegmentIndices2Blobs(indIm, boxes, neighbours)
% This function converts a segmentation index image to blobs
% Note that this is made by mexFelzenSegmentIndex
%
% indIm:        index image in range 1:n, each int denotes segment label
% boxes:        Bounding boxes of the segments
% neighbours:   Matrix which denotes the neighbours

numSegments = max(indIm(:));

% Get all blobs
blobs = cell(numSegments,1);
for i = 1:numSegments
    blobs{i}.rect = boxes(i,:);
    blobs{i}.mask = indIm(boxes(i,1):boxes(i,3), boxes(i,2):boxes(i,4)) == i;
end

if nargin == 3
    % Get the neighbours
    neighbourMat = tril(neighbours,-1);
    [nb,na] = find(neighbourMat == 1);
else
    na = [];
    nb = [];
end