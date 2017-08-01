% Gaussian derivative calculation in given direction and sigma.
% As inputs the following variables have to be transferred:
% data      : 2-dimensional matrix with gray-scale image,
%             can be obtained as
%             data = im2double(rgb2gray(imread(image_file_name)));
% direction : direction of Gaussian derivative, acceptable values 
%             are 'x', 'y' and 'xy'.
% sigma     : value of standard deviation of Gaussian filter
% Example of use:
% gaussDerivativeOfData = gaussianFilter(data, 'x', 3)

function gaussDerivative = gaussianFilter(data, direction, sigma)

x = -ceil(4*sigma):ceil(4*sigma);
G = exp(-x.^2/(2*sigma^2))/(sigma*sqrt(2*pi));
dG = -x.*exp(-x.^2/(2*sigma^2))/((sigma^3)*sqrt(2*pi));

switch (direction)
    case 'smooth'
        % smooth image in x direction
        gaussDerivative = conv2(data, G, 'same');
                % smooth image in y direction
        gaussDerivative = conv2(gaussDerivative, G', 'same'); 

    case 'x'
        % take gaussian derivative in x direction
        gaussDerivative = conv2(data, dG, 'same');
        % smooth image in y direction
        gaussDerivative = conv2(gaussDerivative, G', 'same'); 
        
    case 'y'
        % take gaussian derivative in y direction
        gaussDerivative = conv2(data, dG', 'same');
        % smooth image in x direction
        gaussDerivative = conv2(gaussDerivative, G, 'same');
    case 'xy'
        % take gaussian derivative in x direction
        gaussDerivativeX = conv2(data, dG, 'same');
        % smooth image in y direction
        gaussDerivativeX = conv2(gaussDerivativeX, G', 'same');
        
        % take gaussian derivative in y direction
        gaussDerivativeY = conv2(data, dG', 'same');
        % smooth image in x direction
        gaussDerivativeY = conv2(gaussDerivativeY, G, 'same');
        
        gaussDerivative = sqrt(gaussDerivativeX .* gaussDerivativeX + ...
                               gaussDerivativeY .* gaussDerivativeY);

    otherwise
        fprintf('Error: direction of Gaussian filter should be x y or xy');
        gaussDerivative = 0;
end

