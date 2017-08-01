function imsegs = processSuperpixelImage(segimage, getInfo)
% imsegs = processSuperpixelImage(fn)
% Creates the imsegs structure from a segmentation image

im = double(segimage);
imsegs.imname = 'empty';
imsegs.imsize = size(im);
imsegs.imsize = imsegs.imsize(1:2);
if size(segimage, 3) > 1.
    im = im(:, :, 1) + im(:, :, 2)*256 + im(:, :, 3)*256^2;
    [gid, gn] = grp2idx(im(:));
    imsegs.segimage = uint16(reshape(gid, imsegs.imsize));
    imsegs.nseg = length(gn);
else
    imsegs.segimage = uint16(segimage);
    imsegs.nseg = length(unique(segimage));
end

if getInfo == 1,
    nseg = imsegs.nseg;
    segim = double(imsegs.segimage);
    imh = size(segim, 1);
    adjmat = eye([nseg nseg]);

    % get adjacency
    dx = segim ~= segim(:,[2:end end]);
    dy = segim ~= segim([2:end end], :);
    
    ind1 = find(dy);
    ind2 = ind1 + 1;
    s1 = segim(ind1);
    s2 = segim(ind2);
    
    adjmat(sub2ind([nseg, nseg], s1, s2)) = 1;
    adjmat(sub2ind([nseg, nseg], s2, s1)) = 1;

    ind3 = find(dx);
    ind4 = ind3 + imh;
    s3 = segim(ind3);
    s4 = segim(ind4);
    adjmat(sub2ind([nseg, nseg], s3, s4)) = 1;
    adjmat(sub2ind([nseg, nseg], s4, s3)) = 1;
    imsegs.adjmat = sparse(adjmat);
    
    stats = regionprops(segim, 'Centroid', 'Area','PixelIdxList');
    imsegs.npixels = vertcat(stats(:).Area);
    imsegs.Centroid = vertcat(stats(:).Centroid);
    pixelList = cell(nseg, 1);
    for n = 1:nseg
        pixelList{n} = find(segim == n);
    end
    imsegs.pixelList = pixelList;
end
end

