function [ bestModelOut ] = testBestModelAROut(coeffOut, predLength, filteredDataCall, startDay, model, uniqueDates)
%TESTBESTMODELAROUT tests out-of-sample for all AR-models of order 1 to 5, which
%number of lags is best. 
%   Only a subsample of the data was chosen to calculated the coefficients
%   coeffOut. The prediction is done for predLength days.
%   For every prediction day the mean squared error of the actual implied
%   volatility and the predicted volatility is calculated. The best Model
%   is the model that has the lowest mean squared error most often 

    mseVolaAROut = zeros(5,predLength);
    for ii = 1:5;
        predCoeffAROut = getPredCoeffAROut(coeffOut, predLength, ii);

        for j = 1:predLength
            
            thisDate = uniqueDates(startDay+j-1);
            thisObs = getObs(thisDate,filteredDataCall);
    
            volaAR = evalVola(thisObs,predCoeffAROut(j,:),model);
            mseVolaAROut(ii,j) = getMse(volaAR,thisObs.implVol);
        end
    end
    
    [~, bestModelOutAll] = min(mseVolaAROut);
    bestModelOut = mode(bestModelOutAll);
end

