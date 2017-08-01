function [scores index] = BoxBestOverlap_depre(testBoxes, gtBox)
% [scores index] = BoxBestOverlap(testBoxes, gtBox)
% 
% Get overlap scores (Pascal-wise) for test boxes
%
% test:                    Test boxes
% groundTruthBox:          ground truth box
%
% scores:                  Highest overlap scores for each test box.
% index:                   Index for each test box which ground truth box
%                          is best


numTest = size(testBoxes, 1);
scoreM = zeros(numTest, 1);

for i=1:numTest
    scoreM(i) = GetPascalOverlap(testBoxes(i,:), gtBox);
end

[scores index] = max(scoreM);

