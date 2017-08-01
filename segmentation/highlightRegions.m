function im3d = highlightRegions(im, pix, color)
[imh, imw, imc] = size(im);
imsz = imh * imw;
if imc == 1,
    if islogical(im),
        imReal = uint8(zeros(imh, imw));
        imReal(im) = 255;
    else
        imReal = im;
    end
    im3d = uint8(zeros(imh, imw, 3));
    im3d(:, :, 1) = imReal;
    im3d(:, :, 2) = imReal;
    im3d(:, :, 3) = imReal;
else
    im3d = im;
end
alpha = 0.5;
im3d(pix) = (1- alpha) * im3d(pix) + alpha * color(1);
im3d(pix + imsz) = (1- alpha) * im3d(pix + imsz) + alpha * color(2);
im3d(pix + 2 * imsz) = (1- alpha) * im3d(pix + 2 * imsz) + alpha * color(3);
