function vector = Blob2Vector(blob, im)
% vector = Blob2Vector(blob, image) creates a vector representation of the
% blob. Each entry for vector(i,:) is the i-th pixel colour-value of the
% blob.

% first crop image
vector = im(blob.rect(1):blob.rect(3), blob.rect(2):blob.rect(4),:);


% reshape image and mask
numColours = size(im,3);
vector = reshape(vector, [], numColours, 1)';
mask = reshape(blob.mask, [], 1)';

% Now find all values where the mask is not 0.

% vector = vector(:,find(not(mask == 0)));
vector = vector(:,(mask ~= 0));