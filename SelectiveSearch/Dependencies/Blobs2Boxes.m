function boxes = Blobs2Boxes(blobs)

boxes = zeros(length(blobs), 4);
for i=1:length(blobs)
    boxes(i,:) = blobs{i}.rect;
end
    