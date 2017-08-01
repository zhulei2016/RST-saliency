function blobIm = Blob2Image(blob, im)
% function blobIm = Blob2Image(blob, im)
%
% converts a blob to an image which can be displayed. 

% Crop region
blobIm = im(blob.rect(1):blob.rect(3), blob.rect(2):blob.rect(4),:);

% Multiply with mask
if isa(im, 'uint8')
    blobIm = blobIm .* repmat(uint8(blob.mask),[1,1,size(im,3)]);
else    
    blobIm = blobIm .* repmat(blob.mask,[1,1,size(im,3)]);
end