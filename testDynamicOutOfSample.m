function [bestModelMSETest, bestModelARTest, bestModelVARTest, mse] = testDynamicOutOfSample( filteredDataCall, uniqueDates, k, l )
% Here the out-of-sample tests for modelling the volatility surfaces are
% made. 
%   Therefore only the one year (l=253), three years (l= 759) or six years
%   (l=1528) of the data is taken to evaluate the coefficients. Then the
%   next day is predicted with three different models, the AR model, the
%   VAR model and a model that always takes the last days coefficient as
%   the best prediction for the current day.

bestModelAROut = zeros(k,1);
mseVolaAROut = zeros(k,1);
bestModelVAROut = zeros(k,1);
mseVolaVAROut = zeros(k,1);
mseVolaMod2Out = zeros(k,1);

for j=1:k

%% OUT-OF-SAMPLE TESTING:

filteredDataCall.DayNb = [1:size(filteredDataCall,1)]';
dayVectorStart = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(j),:);
dayVectorEnd = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(l-1+j),:);
dayVectorPred = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(l+j),:);

startOut = dayVectorStart(1);
stopOut = dayVectorEnd(end);
startPred = dayVectorPred(1);
stopPred = dayVectorPred(end);
startDay = l+j;

model = [1,2,3,4,5];
coeffOut = getCoeff(model, filteredDataCall(startOut:stopOut,:));

predLength = size(unique(filteredDataCall(startPred:stopPred,1)),1);

%% Model 0: Autoregressive model
% test out of sample, how many lags are best in AR model:
bestModelAROut(j) = testBestModelAROut(coeffOut, predLength, filteredDataCall, startDay, model, uniqueDates);
% model bestModelAROut(j) performs best => use AR(bestModelAROut(j)) model
predCoeffAROut = getPredCoeffAROut(coeffOut, predLength, bestModelAROut(j));

volaAROut = evalVola(filteredDataCall(startPred:stopPred,:),predCoeffAROut,model);
mseVolaAROut(j) = getMse(volaAROut,filteredDataCall.implVol(startPred:stopPred));


%% Model 1: Vector autoregressive model
bestModelVAROut(j) = testBestModelVAROut(coeffOut, predLength, filteredDataCall, startDay, uniqueDates, model);
% evaluate the parameters of the VAR(bestModelVAROut(j)) model, which models the dynamics of
% the implied volatility surface:
predCoeffVAROut = getPredCoeffVAROut(coeffOut, predLength, bestModelVAROut(j));

% use the predicted coefficients to evaluate the volatility for the next
% day
volaVAROut = evalVola(filteredDataCall(startPred:stopPred,:), predCoeffVAROut, model);

% compare the predicted volatility for the next day with the implied
% volatility for the next day:
mseVolaVAROut(j) = getMse(filteredDataCall.implVol(startPred:stopPred,:),volaVAROut);

%% Model2: coefficients of previous day are used for current day as a comparing model
% evaluate the coefficients of the previous day as the coefficients of the
% current day
predCoeffMod2Out = repmat(coeffOut(end,:),predLength,1);

volaMod2Out = evalVola(filteredDataCall(startPred:stopPred,:), predCoeffMod2Out, model);

mseVolaMod2Out(j) = getMse(filteredDataCall.implVol(startPred:stopPred,:),volaMod2Out);


end

mse = [mseVolaAROut, mseVolaVAROut, mseVolaMod2Out];
[~, numtest] = min(mse');
bestModelMSETest = mode(numtest);

bestModelARTest = mode(bestModelAROut);
bestModelVARTest = mode(bestModelVAROut);
end