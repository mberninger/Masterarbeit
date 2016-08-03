function [ bestModelBICAll ] = testBestModelAR( coeff, nbOfLags )
%TESTBESTMODELAR tests for all AR-models of order 1 to nbOfLags, which
%number of lags is best. 
%   The best number of lags, which is chosen by the smallest BIC, is the output 

bicAR = zeros(nbOfLags,size(coeff,2));

for ii = 1:nbOfLags
    [~, ~, bicAR(ii,:)] = getPredCoeffAR(coeff,ones(6,1)*ii);    
end

[~, bestModelBICAll] = min(bicAR);

end

