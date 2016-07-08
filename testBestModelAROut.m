function [ bestModelOut ] = testBestModelAROut(coeffOut, coeffLength, coeffSize, filteredDataCall, startPred, stopPred, model)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

    mseVolaAROut = zeros(5,1);
    for ii = 1:5;
        predcoeff = evalCoeffAR(coeffOut,coeffLength, coeffSize, ii);

        volaAR = evalVola(filteredDataCall(startPred:stopPred,:),predcoeff(end,:),model);
        mseVolaAROut(ii,:) = getMse(volaAR,filteredDataCall.implVol(startPred:stopPred));
    end
    
    [~, bestModelOut] = min(mseVolaAROut);

end

