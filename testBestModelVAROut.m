function [ bestModelOut ] = testBestModelVAROut(coeffOut, coeffLength, coeffSize, filteredDataCall, startPred, stopPred, model)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

mseVolaVAROut = zeros(5,1);

for ii = 1:5
    Spec = vgxset('n',6,'nAR',ii, 'Constant',true);
    [EstSpec5Out, ~, ~] = vgxvarx(Spec,coeffOut);

    % use these parameters and the previous 5 coefficients from coeffOut to
    % predict the coefficients for the next day:
    beta = evalCoeffVar(coeffOut(coeffLength-coeffSize+1:coeffLength,:),EstSpec5Out.a,EstSpec5Out.AR);

    % use the predicted coefficients to evaluate the volatility for the next
    % day
    predVola = evalVola(filteredDataCall(startPred:stopPred,:), beta(end,:), model);

    % compare the predicted volatility for the next day with the implied
    % volatility for the next day:
    mseVolaVAROut(ii,:) = getMse(filteredDataCall.implVol(startPred:stopPred,:),predVola);
end

[~, bestModelOut] = min(mseVolaVAROut);

end

