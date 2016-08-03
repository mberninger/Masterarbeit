function [mse, rmse] = testDynamicOutOfSample( filteredDataCall, coeff, uniqueDates, k, l, bestModelAROut, bestModelVAROut )
% Here the out-of-sample tests for modelling the volatility surfaces are
% made. 
%   Therefore only three years (l= 759) or six years
%   (l=1528) of the data is taken to evaluate the coefficients. Then the
%   next day is predicted with three different models, the AR model, the
%   VAR model and a model that always takes the last days coefficient as
%   the best prediction for the current day.


mseVolaAROut = zeros(k,1);
mseVolaVAROut = zeros(k,1);
mseVolaMod2Out = zeros(k,1);
rmseVolaAROut = zeros(k,1);
rmseVolaVAROut = zeros(k,1);
rmseVolaMod2Out = zeros(k,1);

for j=1:k

%% OUT-OF-SAMPLE TESTING:

filteredDataCall.DayNb = [1:size(filteredDataCall,1)]';
dayVectorPred = filteredDataCall.DayNb(filteredDataCall.Date == uniqueDates(l+j),:);

startPred = dayVectorPred(1);
stopPred = dayVectorPred(end);

model = [1,2,3,4,5];
% coeffOut = getCoeff(model, filteredDataCall(startOut:stopOut,:));
coeffOut = coeff(j:j+l-1,:);

predLength = size(unique(filteredDataCall(startPred:stopPred,1)),1);

%% Model 0: Autoregressive model
% model bestModelAROut performs best => use AR(bestModelAROut(j)) model
predCoeffAROut = getPredCoeffAROut(coeffOut, predLength, bestModelAROut);

volaAROut = evalVola(filteredDataCall(startPred:stopPred,:),predCoeffAROut,model);
mseVolaAROut(j) = getMse(volaAROut,filteredDataCall.implVol(startPred:stopPred));
rmseVolaAROut(j) = getRmse(volaAROut,filteredDataCall.implVol(startPred:stopPred));


%% Model 1: Vector autoregressive model
% evaluate the parameters of the VAR(bestModelVAROut) model, which models the dynamics of
% the implied volatility surface:
predCoeffVAROut = getPredCoeffVAROut(coeffOut, predLength, bestModelVAROut);

% use the predicted coefficients to evaluate the volatility for the next
% day
volaVAROut = evalVola(filteredDataCall(startPred:stopPred,:), predCoeffVAROut, model);

% compare the predicted volatility for the next day with the implied
% volatility for the next day:
mseVolaVAROut(j) = getMse(filteredDataCall.implVol(startPred:stopPred,:),volaVAROut);
rmseVolaVAROut(j) = getRmse(filteredDataCall.implVol(startPred:stopPred,:),volaVAROut);

%% Model2: coefficients of previous day are used for current day as a comparing model
% evaluate the coefficients of the previous day as the coefficients of the
% current day
predCoeffMod2Out = repmat(coeffOut(end,:),predLength,1);

volaMod2Out = evalVola(filteredDataCall(startPred:stopPred,:), predCoeffMod2Out, model);

mseVolaMod2Out(j) = getMse(filteredDataCall.implVol(startPred:stopPred,:),volaMod2Out);
rmseVolaMod2Out(j) = getRmse(filteredDataCall.implVol(startPred:stopPred,:),volaMod2Out);

end

mse = [mseVolaAROut, mseVolaVAROut, mseVolaMod2Out];
rmse = [rmseVolaAROut, rmseVolaVAROut, rmseVolaMod2Out];
end