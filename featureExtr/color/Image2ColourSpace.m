function [colourIm colourImUInt8] = Image2ColourSpace(im, colourType)
% Changes the colourType of an image
%
% im:           Image, double or UINT8, grayscale (size(im,3) == 1) or Rgb
% colourType:   String denoting colourType. Possibilities:
%               - Rgb (no change)
%               - Hsv
%               - H, H channel of Hsv
%               - C, C from Color Invariance, Geusebroek et al.
%               - HS. HS channels of Hsv
%               - Intensity (grayscale)
%               - RgbNorm, Normalized RGB
%               - RGI, Normalized RG channels plus intensity (B is redundant)
%               - Lab, LAB colour space
%               - Opp, Opponent colour space
%
% colourIm:     Transformed image as a double
% colourImUint8:Transformed image as UINT8

if isa(im, 'double')
    doubleIm = im;
    im = im2uint8(im);
else
    doubleIm = im2double(im);
end

% Adjust for grey values images
if size(im,3) == 1
    im = repmat(im, [1 1 3]);
end

switch colourType
    case 'Rgb' % No conversion ;-)
        colourImUInt8 = im;        
        colourIm = doubleIm;

    case 'Hsv'
        % Convert to HSV
        hsvIm = im2uint8(rgb2hsv(doubleIm));
        colourImUInt8 = hsvIm;
        
        colourIm = im2double(hsvIm);
        
    case 'H'
        % Convert to HSV
        hsvIm = im2uint8(rgb2hsv(doubleIm));
        hIm = repmat(hsvIm(:,:,1), [1 1 3]);
        colourImUInt8 = hIm;
        
        colourIm = im2double(hIm);
        
    case 'C'
        cIm = im2uint8(Rgb2C(doubleIm));
        cIm(:,:,3) = 0;
        
        colourImUInt8 = cIm;
        
        colourIm = im2double(cIm);
        
    case 'HS'
        % Convert to HSV
        hsvIm = im2uint8(rgb2hsv(doubleIm));
        hsvIm(:,:,3) = 0;
        colourImUInt8 = hsvIm;
        
        colourIm = im2double(hsvIm);

    case 'Intensity'
        grayIm = im2uint8(rgb2gray(doubleIm));
        grayIm = repmat(grayIm, [1 1 3]);
        
        colourImUInt8 = grayIm;
        colourIm = im2double(grayIm);
    case 'RgbNorm'
        rgbNormIm = im2uint8(Rgb2Rg(im));
        
        colourImUInt8 = rgbNormIm;
        
        colourIm = im2double(rgbNormIm);        
    case 'RGI'
        % Convert to RGI
        rgiIm = im2uint8(Rgb2Rgi(im));
        colourImUInt8 = rgiIm;
        
        colourIm = im2double(rgiIm);    
    case 'Lab'
        cform = makecform('srgb2lab');
        labIm = applycform(im,cform);
        colourImUInt8 = labIm;
        colourIm = im2double(labIm);
    case 'Opp'
        % Convert to opponent colour space
        oppIm = Rgb2Ooo(im);
        
        % Normalize stuff
        oppIm(:,:,1) = NormalizeArray(oppIm(:,:,1));
        oppIm(:,:,2) = NormalizeArray(oppIm(:,:,2));
        oppIm(:,:,3) = NormalizeArray(oppIm(:,:,3));
        
        % Back to uint8 for the segmentation
        oppIm = im2uint8(oppIm);
        
        colourImUInt8 = oppIm;
        colourIm = im2double(oppIm);
        
    otherwise
        warning('Invalid colour type: %s\n', colorType);
end