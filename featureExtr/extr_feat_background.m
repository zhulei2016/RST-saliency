% extract background features for contrast computation
% (h ,w are size of no paddings)
function feat_bkg = extr_feat_background(chns, h, w, p, bw)
imh = chns.imh; imw = chns.imw;
b = floor( bw * max(h, w) / 400 );
% get pixels in the probable background
[xl, yl] = meshgrid(p : (p + b - 1), p : (p + h - 1)); % left bar
[xr, yr] = meshgrid((p + w - b) : (p + w - 1), p : (p + h - 1));   % right bar
[xt, yt] = meshgrid((p + b) : (p + w - b - 1), p : (p + b - 1));   % top middle bar (shift 1 pix in each side)
[xb, yb] = meshgrid((p + b) : (p + w - b - 1), (p + h - b) : (p + h - 1)); % bottom middle bar
pix_bkg = sub2ind2([imh, imw], [[yl(:); yr(:); yt(:); yb(:)], [xl(:); xr(:); xt(:); xb(:)]]);

feat_bkg = extr_feat_arbitraryRegions(chns, pix_bkg);

if 0 
    im4show = uint8(zeros(imh, imw));
    im4show(pix_bkg) = 255; 
    imshow(im4show);
end
end

