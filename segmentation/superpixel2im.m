function im = superpixel2im(segments, values)
labelNum = length(unique(segments));
[height, width] = size(segments);
sz = height * width;
[~,dims] = size(values);
im = zeros([height, width, dims]);
for i = 1 : labelNum,
    idx = find(segments == i);
    for j = 0 : dims - 1,
        im(idx + j * sz) = values(i, j + 1);
    end
end
end
