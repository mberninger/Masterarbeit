function [ bestModelBIC ] = testBestModelVAR( coeff, nbOfLags )
%TESTBESTMODELVAR tests for all VAR-models of order 1 to nbOfLags, which
%number of lags is best. 
%   The best number of lags, which is chosen by the smallest BIC, is the output 

bic = zeros(nbOfLags,1);

for ii = 1:nbOfLags
    [~,bic(ii,:)] = getPredCoeffVAR(coeff, ii);
end

[~, bestModelBIC] = min(bic);

end

