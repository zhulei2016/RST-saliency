function [segments, new_labels, label_num] = mexSLIC(cluster_colormap,desiredRegions,regularizer)

% Gathering some information
[height, width] = size(cluster_colormap(:, :, 1));

% Get the segments from the SLIC algorithm.
% [pix_label, label_num] = my_slic(double(cluster_colormap),desiredRegions,regularizer,1);
[pix_label, label_num] = my_slic(cluster_colormap,desiredRegions,regularizer,1);

% The labels always start with '0',and sometimes are not continous
org_labels = unique(pix_label);
temp_labels = pix_label;
for i = 1: label_num,
    pix_label(temp_labels == org_labels(i)) = i;
end
new_labels = unique(pix_label);

% TODO: need removed
% lins = 1 : label_num;
% if new_labels ~= lins',
%     error('Error mapping in SLIC labels rearranging!!!');
% end

segments = reshape(pix_label, width, height)';
end