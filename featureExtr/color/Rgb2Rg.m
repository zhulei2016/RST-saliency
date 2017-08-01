function rgIm = Rgb2Rg(rgbIm)
% rgIm = Rgb2Rg(rgbIm)
%
% Transforms RGB image into normalized RGB. Note that the B channel is
% redundant as R+G+B = 1.
%
% rgbIm:            N x M x 3 Rgb image. Doubles in range 0:1. 
%
% rgIm:            N x M x 3 Opponent Image. Doubles again.
%

if isa(rgbIm, 'uint8')
    rgbIm = im2double(rgbIm);
end

%%% OLD
% rgIm(:,:,3) = sum(rgbIm,3);
% intensity = rgIm(:,:,3);
% intensity(intensity == 0) = 1; % Avoid division by zero
% rgIm(:,:,1) = rgbIm(:,:,1) ./ intensity;
% rgIm(:,:,2) = rgbIm(:,:,2) ./ intensity;
% 
% rgIm(:,:,3) = rgIm(:,:,3) ./ 3;
%%% END OLD

total = sum(rgbIm,3);
r = rgbIm(:,:,1) ./ total;
g = rgbIm(:,:,2) ./ total;
b = rgbIm(:,:,3) ./ total;

r(isnan(r)) = 1/3;
g(isnan(g)) = 1/3;
b(isnan(b)) = 1/3;


rgIm(:,:,1) = r;
rgIm(:,:,2) = g;
rgIm(:,:,3) = b;




