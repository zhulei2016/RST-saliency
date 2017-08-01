function [histogram histVals] = Vector2Hist(vector, numBins, min, max)
% histogram = Vector2Hist(vector) makes a histogram of each row of the
% vector. 
% numBins is the number of bins
% min is the minimum value. This value is inclusive.
% max is the maximum value. This value is exclusive(!). Thus, the largest
% bin is in range [n,max).
%
% Update: [histogram histVals] = Vector2Hist(vector, numBins, min, max).
% The extra (optional) argument histVals represents the mean value for each
% bin in the histogram.


histEdges = min:double(max-min)/numBins:max;

for i = 1:size(vector,1)
    v = vector(i,:);
    h = histc(v, histEdges);
    % Discard last bin and add h to histogram. Normalize.
    histogram(i,:) = h(1:end-1) / sum(h(1:end-1));
end
   
histVals = (histEdges(1:end-1) + histEdges(2:end)) / 2.0;
