function cIm = Rgb2C(rgbIm)
% cIm = Rgb2C(rgb)
%
% Transforms RGB image into C-space. This is basically opponent color space
% where the intensity is divided out of the opponent color channels.
%
% rgbIm:            N x M x 3 Rgb image. Doubles in range 0:1. 
%
% cIm:            N x M x 3 Opponent Image. Doubles again.
%
% Strict adherence to Koen's code
% Not that it's a mess, but for SIFT the derivatives 
% and normalization ensure its good in the end

% Get opponent colors
oooIm = Rgb2Ooo(rgbIm);

%%% OLD
% Normalize Intensity CHannel
% maxIntensity = max(max(cIm(:,:,1)));
% if maxIntensity < 0.000001 % Avoid division by zero
%     maxIntensity = 1;
% end

% % add one to avoid division by zero later on
% cIm(:,:,1) = cIm(:,:,1) + 1;
% cIm(:,:,1) = cIm(:,:,1) ./ maxIntensity;
% 
% % Do black Koen Magic
% cIm(:,:,2) = ((cIm(:,:,2) ./ cIm(:,:,1)) / 900) + 0.5;
% cIm(:,:,3) = ((cIm(:,:,3) ./ cIm(:,:,1)) / 900) + 0.5;
%%% END OLD

intensity = oooIm(:,:,1) + 1; % Avoid division by zero
intensity = intensity ./ max(max(intensity));

redGreen = oooIm(:,:,2) ./ intensity;
blueYellow = oooIm(:,:,3) ./ intensity;

cIm(:,:,1) = NormalizeArray(redGreen);
cIm(:,:,2) = NormalizeArray(blueYellow);
cIm(:,:,3) = intensity;