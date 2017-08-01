% efficient color labeling algrithm, the imput image should be in the range
% of [0,1]
function [im_lbl, nColorHist] = colorLabeling(im, tBins)
nColorHist = tBins * tBins * tBins; % total number of bins in a color channel
% % split three channels from a color image
% c1 = im(:,:,1); 
% c2 = im(:,:,2);
% c3 = im(:,:,3);
% % compute the 1dimentional color labels for each pixel
% c11 = min( floor(c1 * tBins(1)) + 1, tBins(1) );
% c22 = min( floor(c2 * tBins(2)) + 1, tBins(2) );
% c33 = min( floor(c3 * tBins(3)) + 1, tBins(3) );
% im_lbl = (c11-1) * tBins(2) * tBins(3) + ...
%     (c22-1) * tBins(3) + ...
%     c33 + 1;

% Fix to work with any type of images.
rgb_image = im2uint8(im);

% Each channel is asiggned to a 0 to 9 value.
a = tBins * tBins - 1;
red_channel = idivide((uint32(a * ((double(rgb_image(:, :, 1)) / 255)))), tBins);
green_channel = idivide((uint32(a * ((double(rgb_image(:, :, 2)) / 255)))), tBins);
blue_channel = idivide((uint32(a * ((double(rgb_image(:, :, 3)) / 255)))), tBins);

% A labeled map is constructed where each values goes from 1 to 1000.
im_lbl = tBins * tBins * red_channel  + tBins * green_channel + blue_channel + 1;
end