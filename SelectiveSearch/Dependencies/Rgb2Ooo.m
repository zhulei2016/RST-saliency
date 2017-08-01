function oIm = Rgb2Ooo(rgb)
% oppIm = Rgb2Opponent(rgb)
%
% Transforms an RGB image into an opponent color image. No normalization is
% done and should be done afterwards.
%
% rgbIm:            N x M x 3 Rgb image. Doubles in range 0:1. 
%
% oppIm:            N x M x 3 Opponent Image. Doubles again.
%
% Jasper: Uses the numbers from the Impala UpoRgb2Ooo.h implementation
% which Koen also seems to use.

if isa(rgb, 'uint8')
    rgb = im2double(rgb);
end

rgb = rgb * 255;

% Intensity
oIm(:,:,1) = 255.0*(rgb(:,:,1) * 0.000233846 + rgb(:,:,2) * 0.00261968 + rgb(:,:,3) * 0.00127135);

% Red-Green
oIm(:,:,2) = 255.0*(rgb(:,:,1) * 0.000726333 + rgb(:,:,2) * 0.000718106+ rgb(:,:,3) * -0.00121377);

% BlueYellow
oIm(:,:,3) = 255.0*(rgb(:,:,1) * 0.000846833 + rgb(:,:,2) * -0.00173932+ rgb(:,:,3) * 0.000221515);

