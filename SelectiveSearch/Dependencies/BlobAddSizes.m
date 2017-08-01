function blobs = BlobAddSizes(blobs)
% This function add size fields to the blobs. Doing this once saves
% computation time.

for i=1:length(blobs)
    blobs{i}.size = sum(sum(blobs{i}.mask));
end
