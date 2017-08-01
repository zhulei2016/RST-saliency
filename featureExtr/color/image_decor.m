% Function: decorrelate input images, the transform matrix is approximately predifined as suggested in Ref. 
% Input: comb_img -  the raw RGB image
%          trans_matrix - decorrelation matrix
% Output: decor_img - the decorrelated images
% Ref: Multi-spectral SIFT for Scene Category Recognition, CVPR 11.
% Author: Yang Xiao @ SCE NTU (hustcowboy@gmail.com)
% Created on 2012.4.23
% Last modified on 2014.11.3

function [decor_img] = image_decor(comb_img, trans_matrix)

%%--------------------------------------------------------------
%% parameters

channel_num = size(comb_img, 3);                        %obtain the number of channels
[row, col] = size(comb_img(:, :, 1));                           %obtain the image size of each channel

[m_row, m_col] = size(trans_matrix); 
for i = 1:m_col
     trans_matrix(:,i) =  trans_matrix(:,i) / sum(abs( trans_matrix(:,i)));     %normalize trans_matrix
end

%%-------------------------------------------------------------
%% transform each channel image to one dimensional
data_array = zeros(row*col, channel_num);
for i = 1:channel_num
    data_array(:, i) = reshape(comb_img(:, :, i), row*col, 1);
end
data_array = double(data_array);

%%-------------------------------------------------------------
%% decorrelation

data_decor_array = data_array * trans_matrix;       %1-d decorrelated image array for each channel

%obtain the offset
[d_row, d_col] = size(data_array);
offset_decor_array = 255 * ones(d_row, d_col);     % offset array

%assign the elements more than 0 in trans_matrix to 0 and abs trans_matrix
[idx_row, idx_col] = find(trans_matrix>0);
for i = 1:length(idx_row)
    trans_matrix(idx_row(i),idx_col(i)) = 0;
end
trans_matrix = abs(trans_matrix);

data_decor_array = data_decor_array + offset_decor_array*trans_matrix;

%%-------------------------------------------------------------
%% Output
[d_dim, output_channel_num] = size(data_decor_array);
decor_img = zeros(row, col, channel_num);
for i = 1:output_channel_num
    decor_img(:, :, i) = reshape(data_decor_array(:,i), row, col);
end




