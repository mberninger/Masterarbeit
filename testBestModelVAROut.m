function [ bestModelOut, bestModelOutR ] = testBestModelVAROut(coeffOut, predLength, filteredDataCall, startDay, uniqueDates, model)
%TESTBESTMODELVAROUT tests out-of-sample for all VAR-models of order 1 to 5, which
%number of lags is best. 
%   Only a subsample of the data was chosen to calculated the coefficients
%   coeffOut. The prediction is done for predLength days.
%   For every prediction day the mean squared error of the actual implied
%   volatility and the predicted volatility is calculated. The best Model
%   is the model that has the lowest mean squared error most often 

mseVolaVAROut = zeros(5,predLength);
rmseVolaVAROut = zeros(5,predLength);

for ii = 1:5
    predCoeffVAROut = getPredCoeffVAROut(coeffOut,predLength,ii);

    for j = 1:predLength
        
        thisDate = uniqueDates(startDay+j-1);
        thisObs = getObs(thisDate,filteredDataCall);
        
        % use the predicted coefficients of the ii'th prediction day to evaluate the volatility for the next
        % day
        volaVAROut = evalVola(thisObs, predCoeffVAROut(j,:), model);

        % compare the predicted volatility for the next day with the implied
        % volatility for the next day:
        mseVolaVAROut(ii,j) = getMse(thisObs.implVol,volaVAROut);
        rmseVolaVAROut(ii,j) = getRmse(thisObs.implVol,volaVAROut);
    end
end

[~, bestModelOutAll] = min(mseVolaVAROut);
bestModelOut = mode(bestModelOutAll);
[~, bestModelOutAllR] = min(rmseVolaVAROut);
bestModelOutR = mode(bestModelOutAllR);
end

