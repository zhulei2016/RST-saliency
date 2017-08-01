% function demoIonut

% This demo shows how to use the software described in our ICCV paper: 
%   Segmentation as Selective Search for Object Recognition,
%   K.E.A. van de Sande, J.R.R. Uijlings, T. Gevers, A.W.M. Smeulders, ICCV 2011
%%

fprintf('Demo of how to run the code for:\n');
fprintf('   K. van de Sande, J. Uijlings, T. Gevers, A. Smeulders\n');
fprintf('   Segmentation as Selective Search for Object Recognition\n');
fprintf('   ICCV 2011\n\n');

% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    fprintf('Compiling the anisotropic gauss filtering of:\n');
    fprintf('   J. Geusebroek, A. Smeulders, and J. van de Weijer\n');
    fprintf('   Fast anisotropic gauss filtering\n');
    fprintf('   IEEE Transactions on Image Processing, 2003\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://staff.science.uva.nl/~mark/downloads.html#anigauss\n\n');
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    fprintf('Compiling the segmentation algorithm of:\n');
    fprintf('   P. Felzenszwalb and D. Huttenlocher\n');
    fprintf('   Efficient Graph-Based Image Segmentation\n');
    fprintf('   International Journal of Computer Vision, 2004\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://www.cs.brown.edu/~pff/segment/\n');
    fprintf('Note: A small Matlab wrapper was made. See demo.m for usage\n\n');
%     fprintf('   
    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab'};

% MAURO: THIS IS PROBABLY WHAT YOU NEED TO LOOK AT MOST
% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFill, @SSSimTextureSizeFill};

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
kRange = [50 100];% = 200; % controls size of segments of initial segmentation. 
sigma = 0.8;

% As an example, use a single image
images = {'000015.jpg'};
im = imread(images{1});

% Perform Selective Search
idx = 1;
boxes = cell(length(kRange) * length(colorTypes), 1);
for k = kRange
    minSize = k;
    for colorType = colorTypes
        colorType = colorType{1};
        boxes{idx} = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
        idx = idx + 1;
    end
end

boxes = cat(1, boxes{:});
boxes = BoxRemoveDuplicates(boxes);

% % Show boxes
% ShowRectsWithinImage(boxes, 5, 5, im);
 
