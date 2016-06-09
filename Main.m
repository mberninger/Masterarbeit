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

%% evaluate the row number where day changes
% get unique dates and row number, where day changes
[uniqueDates, dataPerDay] = unique(filteredDataCall.Date);

% NOTE: old implementation skips observations for last date
% attach value of (last index + 1) to dates
dayChanges = [dataPerDay; size(filteredDataCall, 1)+1];


%% FITTING THE IMPLIED VOLATILITY SURFACES for call options
%
%% OUT OF SAMPLE TESTING:
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
    
%% IN SAMPLE TESTING
%% Goodness-of-fit:
%   mean square error: 0 = perfect fit
%   root mean squared error: 0 = perfect fit

% evaluate volatility with modelled coefficients
vola = evalVola(filteredDataCall, coeff5, model5 );

% test mean squared and root mean squared error evaluated and implied volatility 
mse = getMse(vola,filteredDataCall.implVol);
rmse = getRmse(vola,filteredDataCall.implVol);
    
%% after in-sample and out-of-sample testing: model 5 is chosen:
model = [1,2,3,4,5];
coeff = getCoeff(model, filteredDataCall);

%% TODO: next steps
% - some descriptive statistics: 
%   - observations per day
%   - observed maturities per day
%   - number of filtered observations
%   - ...

%% properties of the estimated coefficients:
% plot histogram of estimated coefficient and normal pdf to compare
figure;
plotCoeffDensity(coeff(:,5));
% plot coefficients of the model over time -> not constant, but time
% dependent:
figure;
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('level','slope moneyness','curvature moneyness','slope time to maturity','curvature time to maturity','slope cross-product term','Location','southwest')
title('Model coefficients')
% dependency of different coefficients
depOfCoeff = corr(coeff);

%% MODELLING THE DYNAMICS OF THE IMPLIED VOLATILITY SURFACES
%% IN SAMPLE TESTING:
%% Model 1: Vector autoregressive model:
Spec = vgxset('n',6,'nAR',1, 'Constant',true);
[EstSpec1, ~, llh1] = vgxvarx(Spec,coeff);
Spec = vgxset('n',6,'nAR',2, 'Constant',true);
[EstSpec2, ~, llh2] = vgxvarx(Spec,coeff);
Spec = vgxset('n',6,'nAR',3, 'Constant',true);
[EstSpec3, ~, llh3] = vgxvarx(Spec,coeff);
Spec = vgxset('n',6,'nAR',4, 'Constant',true);
[EstSpec4, ~, llh4] = vgxvarx(Spec,coeff);
Spec = vgxset('n',6,'nAR',5, 'Constant',true);
[EstSpec5, ~, llh5] = vgxvarx(Spec,coeff);

aic = [aicbic(llh1,1),aicbic(llh2,2),aicbic(llh3,3),aicbic(llh4,4),aicbic(llh5,5)];

[~,bic1] = aicbic(llh1,1,1908);
[~,bic2] = aicbic(llh2,2,1908);
[~,bic3] = aicbic(llh3,3,1908);
[~,bic4] = aicbic(llh4,4,1908);
[~,bic5] = aicbic(llh5,5,1908);

bic = [bic1, bic2, bic3, bic4, bic5];

clear bic1 bic2 bic3 bic4 bic5;
clear llh1 llh2 llh3 llh4 llh5;

estParam1 = evalCoeffVar(coeff,EstSpec1.a,EstSpec1.AR);
estParam2 = evalCoeffVar(coeff,EstSpec2.a,EstSpec2.AR);
estParam3 = evalCoeffVar(coeff,EstSpec3.a,EstSpec3.AR);
estParam4 = evalCoeffVar(coeff,EstSpec4.a,EstSpec4.AR);
estParam5 = evalCoeffVar(coeff,EstSpec5.a,EstSpec5.AR);

mse1 = getMse(coeff,estParam1);
mse2 = getMse(coeff,estParam2);
mse3 = getMse(coeff,estParam3);
mse4 = getMse(coeff,estParam4);
mse5 = getMse(coeff,estParam5);

%-> model5 performs best

%% Model 2: coefficients of previous day are used for current day as a comparing model
paramMod2 = getParamMod2(coeff);

mseMod2 = getMse(coeff,paramMod2);

% -> VAR(5) model performs best

clear mse1 mse2 mse3 mse4 
clear EstSpec1 EstSpec2 EstSpec3 EstSpec4
clear estParam1 estParam2 estParam3 estParam4
clear Spec

%% OUT-OF-SAMPLE TESTING:
%% Model 1: Vector autoregressive model
% only the first year is taken to evaluate the coefficients for the
% volatility surface: (this can equally be done for the first two years and
% so on, remember to choose trading days!)
[~, stopOut] = getRowsOfDate(filteredDataCall,2007,06,29);
[startPred, stopPred] = getRowsOfDate(filteredDataCall,2007,07,02);

model = [1,2,3,4,5];
coeffOut = getCoeff(model, filteredDataCall(1:stopOut,:));

[coeffLength, coeffSize] = size(coeffOut);

% evaluate the parameters of the VAR(5) model, which models the dynamics of
% the implied volatility surface:
Spec = vgxset('n',6,'nAR',5, 'Constant',true);
[EstSpec5Out, ~, ~] = vgxvarx(Spec,coeffOut);

% use these parameters and the previous 5 coefficients from coeffOut to
% predict the coefficients for the next day:
beta = evalCoeffVar(coeffOut(coeffLength-coeffSize+1:coeffLength,:),EstSpec5Out.a,EstSpec5Out.AR);

% use the predicted coefficients to evaluate the volatility for the next
% day
predVola = evalVola(filteredDataCall(startPred:stopPred,:), beta(end,:), model);

% compare the predicted volatility for the next day with the implied
% volatility for the next day:
mse5OutVola = getMse(filteredDataCall.implVol(startPred:stopPred,:),predVola);

%% Model2: coefficients of previous day are used for current day as a comparing model
% evaluate the coefficients of the previous day as the coefficients of the
% current day
paramMod2Out = getParamMod2(coeffOut);

predVolaMod2 = evalVola(filteredDataCall(startPred:stopPred,:), paramMod2Out(coeffLength,:), model);

mse5OutVolaMod2 = getMse(filteredDataCall.implVol(startPred:stopPred,:),predVolaMod2);

