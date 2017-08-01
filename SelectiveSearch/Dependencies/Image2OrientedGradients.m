function oGIm = Image2OrientedGradients(im, sigma)
% Converts image into gray image. Then creates a n x m x 8 array where for
% each of 8 orientations (starting with y, and going clockwise), a
% magnitude is given. Note that per point only three of these magnitures
% are larger than zero.
%
% im:       The image
% sigma:    Gaussian scale

% Convert to proper image class
if isa(im, 'uint8')
    im = im2double(im);
end

if size(im,3) == 3
    im = rgb2gray(im);
end

% Calculate gaussian derivatives in 4 directions
% imX  = anigauss(im, sigma, sigma, 0, 1, 0);
% imXY = anigauss(im, sigma, sigma, 45, 1, 0);
imXY = anigauss_mex(im, sigma, sigma, 45, 1, 0);
% imY  = anigauss(im, sigma, sigma, 90, 1, 0);
% imYX  = anigauss(im, sigma, sigma, 135, 1, 0);
imYX  = anigauss_mex(im, sigma, sigma, 135, 1, 0);

% Allocate memory
oGIm = zeros(size(im,1), size(im,2), 8);

% Get the positive values in each direction.

% oGIm(:,:,1) = imX .* (imX > 0);   % x 
oGIm(:,:,2) = imXY .* (imXY > 0); % xy
% oGIm(:,:,3) = imY .* (imY > 0);   % y
oGIm(:,:,4) = imYX .* (imYX > 0); % -x, y
% oGIm(:,:,5) = -imX .* (imX < 0);  % -x
oGIm(:,:,6) = -imXY .* (imXY < 0);% -x, -y
% oGIm(:,:,7) = -imY .* (imY < 0);  % -y
oGIm(:,:,8) = -imYX .* (imYX < 0);% x, -y

imX = gaussianFilter(im, 'x', sigma);
imY = gaussianFilter(im, 'y', sigma);

imYPos = imY > 0;
imYNeg = imY < 0;
imXPos = imX > 0;
imXNeg = imX < 0;

oGIm(:,:,1) = imY .* imYPos; % y
% oGIm(:,:,2) = imXY .* (imYPos & imXPos); % xy
oGIm(:,:,3) = imX .* (imXPos); % x
% oGIm(:,:,4) = imXY .* (imYNeg & imXPos); % x -y
oGIm(:,:,5) = -imY .* (imYNeg); % -y
% oGIm(:,:,6) = imXY .* (imYNeg & imXNeg); % -x -y
oGIm(:,:,7) = -imX .* (imXNeg); % -x
% oGIm(:,:,8) = imXY .* (imYPos & imXNeg); % y -x
