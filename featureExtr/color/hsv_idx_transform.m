%Function: transform RGB image to the 8-bit HSV index image for color CENTRIST
%Input: 
% rgb_img    -RGB image
%Output:
% idx_img     -8-bit HSV index image
% Author: Yang Xiao @ IMI NTU (hustcowboy@gmail.com)
% Created on 2013.2.13
% Last modified on 2013.2.14

function [idx_img] = hsv_idx_transform(rgb_img)

[img_h, img_w, n_channel] = size(rgb_img);

hsv_img = rgb2hsv(rgb_img);     %tansform RGB to HSV

%HSV 8-bit index image
idx_img = floor(hsv_img(:,:,3)*255/8) * 8 + floor(hsv_img(:,:,2)*255/64) * 2 + floor(hsv_img(:,:,1)*255/128);


