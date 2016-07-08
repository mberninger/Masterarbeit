function [ bestModelBIC ] = testBestModelAR( coeff )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

bicAR = zeros(5,size(coeff,2));

for ii = 1:5
    [~, ~, bicAR(ii,:)] = getParamAR(coeff,ii);    
end

[~, bestModelBICAll] = min(bicAR);
bestModelBIC = mode(bestModelBICAll');

end

