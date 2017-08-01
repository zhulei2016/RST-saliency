function gridmap = showGrid_DownSamplingImage(image, segments)
% Overaly segmentation
[sx,sy]=vl_grad(double(segments), 'type', 'central') ;
s = find(sx | sy) ;
% gridmap = image ;
% gridmap(s) =244;
% gridmap(s+numel(image(:,:,1))) =164;
% gridmap(s+2*numel(image(:,:,1))) =96;
% gridmap = uint8(zeros(size(image)));
% gridmap(s) =255;
% gridmap(s+numel(image(:,:,1))) =0;
% gridmap(s+2*numel(image(:,:,1))) =0;

% gridmap([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 255 ;
%grid([s s+numel(image(:,:,1)) s+2*numel(image(:,:,1))]) = 255 ;


% for i = 1:length(centrd),
%     idx = sub2ind(size(image(:,:,1)), floor(centrd(i,2)), floor(centrd(i, 1)));
%     gridmap([idx idx+numel(image(:,:,1)) idx+2*numel(image(:,:,1))]) = 0;
% end
% gridmap = zeros(size(image(:, :, 1)));
% gridmap(s) = 255 ;
% 
% % Get the labels of all  segments
% dsplmap = image ;
% seg_labels = unique(segments);
% for i = 1: length(seg_labels),
%     [r, c] = find(segments == seg_labels(i));
%     for j = 1: length(r),
%         dsplmap(r(j), c(j), :) = centrd(i, 3:5);
%     end
% end
% figure,
% subplot(1, 2, 1), imshow(gridmap);
% subplot(1, 2, 2), imshow(dsplmap);
% end

a = 0;
[h, w, c] = size(image); image_u = zeros(h, w, 3);
if c == 1,
    image_u(:, :, 1) = image; image_u(:, :, 2) = image; image_u(:, :, 3) = image;
else
    image_u = image;
end
image_u = im2uint8(image_u);
blackmap = uint8(zeros(size(image_u)));
gridmap = (1 - a) * image_u + a * blackmap;
gridmap(s) =255;
gridmap(s+numel(image_u(:,:,1))) =215;
gridmap(s+2*numel(image_u(:,:,1))) =0;

end
