function img = highlightSegments(rgb_image, segments, givenSegs, color, withBorder)
%   initialize the output
% if isdouble(rgb_image(:, :, 1)),
if isa(rgb_image,'double')
    img = im2uint8(rgb_image);
else
    img = rgb_image;
end

[imgH, imgW] = size(img(:, :, 1));
sz = imgW * imgH;
%   if borders are needed, highlight the borders
if withBorder,
    img = showGrid_DownSamplingImage(img, segments);
end
%   highlight the given segments
for i = 1 : length(givenSegs),
    ind = find(segments == givenSegs(i));
    img(ind) =color(1);
    img(ind + sz) =color(2);
    img(ind + 2 * sz) =color(3);
end
end