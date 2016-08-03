function [ bestModelAROut, bestModelAROutR, bestModelVAROut, bestModelVAROutR ] = getBestLagNb( filteredData, coeff, uniqueDates, k, l )
%GETBESTLAGNB evaluates the best number of lags for an AR- and a VAR-model
%   the output are four vectors which contain the number of lags that has
%   the smallest MSE/RMSE for every day

bestModelAROut = zeros(k,1);
bestModelVAROut = zeros(k,1);
bestModelAROutR = zeros(k,1);
bestModelVAROutR = zeros(k,1);

for j=1:k
startDay = l+j;

model = [1,2,3,4,5];
% coeffOut = getCoeff(model, filteredData(startOut:stopOut,:));
coeffOut = coeff(j:j+l-1,:);

predLength = 1;

% Model 0: Autoregressive model
    % test out of sample, how many lags are best in AR model:
    [bestModelAROut(j), bestModelAROutR(j)] = testBestModelAROut(coeffOut, predLength, filteredData, startDay, model, uniqueDates);

% Model 1: Vector autoregressive model
    [bestModelVAROut(j), bestModelVAROutR(j)] = testBestModelVAROut(coeffOut, predLength, filteredData, startDay, uniqueDates, model);

end

end

