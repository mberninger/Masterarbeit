function [ bestModelBIC ] = testBestModelVAR( coeff )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

bic = zeros(5,1);


for ii = 1:5
    [~,bic(ii,:)] = getParamVAR(coeff, ii);
end

[~, bestModelBICAll] = min(bic);
bestModelBIC = mode(bestModelBICAll');

end

