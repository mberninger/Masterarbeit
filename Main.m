% THIS IS MY MAIN SCRIPT
clear;
clc;
close all;

%% load Dax-optiondata
load data;

%% split data up in calls and puts, evaluate and add implied volatilities, filter the data and evaluate and add the moneyness

% filtering values:
% 1: check upper and lower bounds of option prices:
        % upper bound call: p (option price) < s_t (underlying)
        % upper bound put: p < k (strike price) * exp(-r (interest rate)* t (time to maturity))
        % lower bound call: max(s_t-k*exp(-rt),0) < p
        % lower bound put: max(k*exp(-rt)-s_t,0) < p
% 2: check for negative time values and remove them
% 3: check time to maturity, it should be between 20 and 510 days
% 4: evaluate and check moneyness, it should be between 0.8 and 1.2 
% 5: check option price, it should be bigger than 5
% 6: check implied volatilities, it should be between 5 and 50 percent

timeToMaturityLowerBound = 20;
timeToMaturityUpperBound = 510;
mnyNessLowerBound = 0.8;
mnyNessUpperBound = 1.2;
optionPrice = 5;
implVolLowerBound = 0.05;
implVolUpperBound = 0.5;

filteredDataCall = getFilteredDataCall(data, timeToMaturityLowerBound, timeToMaturityUpperBound, mnyNessLowerBound, mnyNessUpperBound, optionPrice, implVolLowerBound, implVolUpperBound);
filteredDataPut = getFilteredDataPut(data, timeToMaturityLowerBound, timeToMaturityUpperBound, mnyNessLowerBound, mnyNessUpperBound, optionPrice, implVolLowerBound, implVolUpperBound);

clear timeToMaturityLowerBound timeToMaturityUpperBound mnyNessLowerBound mnyNessUpperBound optionPrice implVolLowerBound implVolUpperBound;

%% model implied volatilities for call options
%
%% evaluate the row number where day changes
% get unique dates and row number, where day changes
[uniqueDates, dataPerDay] = unique(filteredDataCall.Date);

% NOTE: old implementation skips observations for last date
% attach value of (last index + 1) to dates
dayChanges = [dataPerDay; size(filteredDataCall, 1)+1];

%% get the goodness of fit out-of-sample and AIC in-sample for all possible models, to find the one that fits best
% choose percentage for out-of-sample data in first input variable
allModels = [1,2,0,0,0;
    1,3,0,0,0;
    1,3,5,0,0;
    1,2,3,5,0;
    1,2,3,4,5];
nRep = 100;
% [mseOutOfSample, rmseOutOfSample] = evalMseRmse(allModels, nRep, 0.8, uniqueDates, filteredDataCall);
load('mseOutOfSample.mat');
load('rmseOutOfSample.mat');
modelAIC = evalModelCriterion(allModels, filteredDataCall);

%% the different models are compared in order to find the bestModel
[ best, fre, ~, ~, allDaysMSE ] = get3DBestModel(mseOutOfSample, uniqueDates, nRep);
[ bestR, freR, ~, ~, allDaysRMSE ] = get3DBestModel(rmseOutOfSample, uniqueDates, nRep);
[ bestA, freA, allDaysAIC ] = getBestModel(modelAIC);

% the different goodness of fit measures are compared for every day
bestModelPerDay = table((1:1908)', allDaysMSE, allDaysRMSE, allDaysAIC, 'VariableNames', {'Days','MSE','RMSE','AIC'});
diffBestModels = bestModelPerDay(bestModelPerDay.MSE ~= bestModelPerDay.RMSE | bestModelPerDay.MSE ~= bestModelPerDay.AIC, :);
bestModelIs5 = bestModelPerDay(bestModelPerDay.MSE == bestModelPerDay.RMSE & bestModelPerDay.MSE == bestModelPerDay.AIC & bestModelPerDay.MSE == 5, :);
bestModelIs4 = bestModelPerDay(bestModelPerDay.MSE == bestModelPerDay.RMSE & bestModelPerDay.MSE == bestModelPerDay.AIC & bestModelPerDay.MSE == 4, :);
bestModelIs3 = bestModelPerDay(bestModelPerDay.MSE == bestModelPerDay.RMSE & bestModelPerDay.MSE == bestModelPerDay.AIC & bestModelPerDay.MSE == 3, :);
bestModelIs2 = bestModelPerDay(bestModelPerDay.MSE == bestModelPerDay.RMSE & bestModelPerDay.MSE == bestModelPerDay.AIC & bestModelPerDay.MSE == 2, :);
bestModelIs1 = bestModelPerDay(bestModelPerDay.MSE == bestModelPerDay.RMSE & bestModelPerDay.MSE == bestModelPerDay.AIC & bestModelPerDay.MSE == 1, :);
clear allDaysMSE allDaysRMSE allDaysAIC;

%% find coefficients for model; choose model coefficients: 
% choose from possible explanatory variables: 1 = moneyness, 2 =
% moneyness^2, 3 = timeToMaturity, 4 = timeToMaturity^2, 5 =
% moneyness*timeToMaturity
model3 = [1,3,5];
coeff3 = getCoeff(model3, filteredDataCall);
model4 = [1,2,3,5];
coeff4 = getCoeff(model4, filteredDataCall);
model5 = [1,2,3,4,5];
coeff5 = getCoeff(model5, filteredDataCall);

%% plot coefficients of model
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('a','b','c','d','e','f')
title('Model coefficients')
% TODO: find suitable names for coefficients

%% Goodness-of-fit:  
%   mean square error: 0 = perfect fit
%   root mean squared error: 0 = perfect fit

% evaluate volatility with modelled coefficients
vola = evalVola(filteredDataCall, coeff, model );

% test mean squared and root mean squared error evaluated and implied volatility 
mse = getMse(vola,filteredDataCall.implVol);
rmse = getRmse(vola,filteredDataCall.implVol);

%% plot volatility surface with estimated coefficients
% choose the day in the first input variable
% the boundarys for the moneyness and the time to maturity are the same as
% chosen for filtering the data, so
    % 0.8 < moneyness < 1.2
    % 20 < timeToMaturity .*225 < 510
    tag = 97;
    plotSurface(tag,coeff3,model3,filteredDataCall,dayChanges);
    plotSurface(tag,coeff4,model4,filteredDataCall,dayChanges);
    plotSurface(tag,coeff5,model5,filteredDataCall,dayChanges);
%% TODO: next steps
% - goodness-of-fit: how good does estimated smooth surface describe real
% implied volatilities?
            % still ToDo: out-of-sample goodness-of-fit

% - are all explanatory variables required, or could a more sparse model
% (e.g. moneyness and maturity only) provide a better solution?
% NOTE: adding explanatory variables does always increase IN-SAMPLE fit.
% But more sparse models can be better OUT-OF-SAMPLE
% - conduct out-of-sample forecast for real future option prices with
% given estimated models

% - create function to plot smooth surface for given coefficients (find
% meaningful ranges for x and y values (moneyness, maturity) 
            % => done
% - plot smooth surface vs implied volatility observations
            % => done
% - make plot variables with regards to parameters: estimated volatility
% surfaces of different models should be comparable

% - how sensitive are all results with regards to chosen data filtering?
% - some descriptive statistics: 
%   - observations per day
%   - observed maturities per day
%   - number of filtered observations
%   - ...

% - visualize dependency between estimated coefficients: 
%   - are they independent?
%   - is it reasonable to model them in 5 separate univariate AR models, or
%     do we need a 5-dimensional joint model

%% dependency of estimated coefficients
% depOfCoeff = corr(coeff);
% 
% 
% %% fit VAR model
% Spec = vgxset('n',6,'nAR',1, 'Constant',true);
% EstSpec = vgxvarx(Spec,coeff);
% % simulate coeff for 100 obs
% H = vgxsim(EstSpec,100);
% 
% %% plot simulated coefficients of model
% figure;
% plot(1:100, H)
% grid on
% grid minor
% datetick 'x'
% legend('a','b','c','d','e')
% title('Model coefficients')
% 
% %% plot volatility surface of simulated model for day k
% % choose k 
% k = 1;
% [X,Y] = meshgrid(0.8:0.02:1.2,20/225:0.1:510/225);
% Z = H(k,1) + H(k,2) .* X + H(k,3) .* X.^2 + H(k,4) .* Y + H(k,5) .* X .* Y;
% alphaVal = 0.5;
% figure
% surface(X,Y,Z,'FaceAlpha', alphaVal)
% grid on
% grid minor
view(3)