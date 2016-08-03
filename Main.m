%% THIS IS MY MAIN SCRIPT
% For the code of all tables and figures, see figuresAndTables.m

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

% in these master thesis call and put options are examined together:
filteredData = [filteredDataCall; filteredDataPut];
filteredData = sortrows(filteredData,'Date','ascend');

clear timeToMaturityLowerBound timeToMaturityUpperBound mnyNessLowerBound mnyNessUpperBound optionPrice implVolLowerBound implVolUpperBound;

%% evaluate the row number where day changes
% get unique dates and row number, where day changes
[uniqueDates, dataPerDay] = unique(filteredData.Date);

% NOTE: old implementation skips observations for last date
% attach value of (last index + 1) to dates
dayChanges = [dataPerDay; size(filteredData, 1)+1];

clear dataPerDay dataPerDayPut;

%% FITTING THE IMPLIED VOLATILITY SURFACES for call and put options    
%% IN SAMPLE TESTING:
% in-sample test for all 5 models, evaluating the mean of R², the mean of
% adj R², MSE, RMSE and the mean of the AIC in order to get best model
allModels = [1,2,0,0,0;
    1,3,0,0,0;
    1,3,5,0,0;
    1,2,3,5,0;
    1,2,3,4,5];

    % due to long calculations, some matrices are stored and loaded, their
    % calculations are always included before the loading of the matrix
% modelAIC = evalModelCriterion(allModels, filteredData);
load('modelAICCallAndPut.mat');
bestModelInSample = getBestInSampleModel( filteredData, allModels, modelAIC );

%% OUT OF SAMPLE TESTING:
%% get the goodness of fit out-of-sample for all possible models, to find the one that fits best
% choose nRep, the number of repetitions and the percentage for
% out-of-sample data in first input variable (e.g. 0.8)
nRep = 100;

    % again, due to long calculations the matrices are also saved
% [mseOutOfSample, rmseOutOfSample] = evalMseRmse(allModels, nRep, 0.8, uniqueDates, filteredData);
load('mseOutOfSampleCallAndPut.mat');
load('rmseOutOfSampleCallAndPut.mat');
    
%% after in-sample and out-of-sample testing: model 5 is chosen for further calculations:
model = [1,2,3,4,5];
    % these coefficients are used very often and therefore are saved in a
    % matrix:
% coeff = getCoeff(model, filteredData);
load('coeff.mat')
vola = evalVola(filteredData, coeff, model);

%% MODELLING THE DYNAMICS OF THE IMPLIED VOLATILITY SURFACES
%% IN SAMPLE TESTING:
%% Model 0: AR model for every chosen coefficient:
% test how many lags (1-5 are tested) are best when an AR model is used:
bestModelAR = testBestModelAR(coeff, 5);
% lag 5 is best => AR(5) model is used
predCoeffAR = getPredCoeffAR(coeff, bestModelAR);

volaAR = evalVola(filteredData,predCoeffAR,model);
mseVolaAR = getMse(volaAR,filteredData.implVol);
rmseVolaAR = getRmse(volaAR,filteredData.implVol);

%% Model 1: Vector autoregressive model:
% test how many lags (1-5 are tested) are best when an VAR model is used:
bestModelVAR = testBestModelVAR(coeff, 5);
% lag 3 is best => AR(3) model is used
predCoeffVAR = getPredCoeffVAR(coeff, bestModelVAR);

volaVAR = evalVola(filteredData,predCoeffVAR,model);
mseVolaVAR = getMse(volaVAR,filteredData.implVol);
rmseVolaVAR = getRmse(volaVAR,filteredData.implVol);

% -> comparing mseVolaVAR and mseVolaAR shows that model 1 performs better
% than model 0

%% Model 2: coefficients of previous day are used for current day as a comparing model
predCoeffMod2 = getPredCoeffMod2(coeff);

volaMod2 = evalVola(filteredData,predCoeffMod2,model);
mseVolaMod2 = getMse(volaMod2,filteredData.implVol);
rmseVolaMod2 = getRmse(volaMod2,filteredData.implVol);

% -> VAR(3) model performs best in-sample

clear bestModelAR bestModelVAR predCoeffAR predCoeffMod2 predCoeffVAR volaAR volaVAR
%% OUT-OF-SAMPLE TESTING: for the AR-model, the VAR-model, model2 and the Kalman filter
% Here the out-of-sample tests for modelling the volatility surfaces are
% made. 
%   Choose timeWindow, the number of days that are taken to calculate the
%   coefficients in sample. Then the next day, timeWindow+1, is predicted.
%   This is done nRep-times. For each time the estimation window for the
%   out-of-sample window moves one day forward. Then the mean squared error
%   and the root mean squared error for the predicted day
%   is calculated. This leads to nRep mse and nRep rmse values. In the
%   end the model is chosen, which has the smallest mean, standard
%   deviation, minimum and maximum (see table 6.7)

nRep = 100;
timeWindow = 1528;

    % due to long calculations these matrices are saved and can be loaded
% [bestModelAROut, bestModelAROutR, bestModelVAROut, bestModelVAROutR] = getBestLagNb( filteredData, coeff, uniqueDates, nRep, timeWindow);
load('bestModelAROut6years.mat')
[~, modelChange] = unique(sort(bestModelAROut(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),modelChange(4)-modelChange(3),modelChange(5)-modelChange(4),length(bestModelAROut)+1-modelChange(5)];
[~,bestModelAROutLagNb] = max(freqBestMSE);

load('bestModelVAROut6years.mat')
[~, modelChangeR] = unique(sort(bestModelVAROut(:,1)));
freqBestMSER = [modelChangeR(2)-modelChangeR(1),modelChangeR(3)-modelChangeR(2),modelChangeR(4)-modelChangeR(3),modelChangeR(5)-modelChangeR(4),length(bestModelVAROut)+1-modelChangeR(5)];
[~,bestModelVAROutLagNb] = max(freqBestMSER);

clear bestModelAROut bestModelVAROut modelChange freqBestMSE modelChangeR freqBestMSER


% after having found the best number of lags for the AR and the VAR-model,
% they are applied in this function to evaluate the MSE and the RMSE:
    % due to long calculations these matrices are saved and can be loaded
[mse, rmse] = testDynamicOutOfSample(filteredData, coeff, uniqueDates, nRep, timeWindow, bestModelAROutLagNb, bestModelVAROutLagNb);
% load('mseVolaAllMod6yearsOutNew.mat')
% load('rmseVolaAllMod6yearsOutNew.mat')


% -> The VAR(1) Model is better than the AR-Model and model 2, as it has
% the smallest mean and standard deviation of the MSE and the RMSE values


%% THE KALMAN FILTER MODEL FOR THE DYNAMIC OF THE VOLATILITY CURVE
%% IN SAMPLE TESTING:

coeffKalman = getPredCoeffKalman(coeff,uniqueDates,filteredData,vola);

volaKalman = evalVola(filteredData,coeffKalman,model);

mseVolaKalman = getMse(filteredData.implVol,volaKalman);
rmseVolaKalman = getRmse(filteredData.implVol,volaKalman);

%% OUT OF SAMPLE TESTING:
    % due to long calculations these matrices are saved and can be loaded
% [mseVolaKalmanOut,rmseVolaKalmanOut] = getPredCoeffKalmanOut(uniqueDates, filteredData, coeff, vola, nRep, timeWindow);
load('mseVolaKalman6yearsOutNew.mat')
load('rmseVolaKalman6yearsOutNew.mat')

mseVolaVARKalman = [mse(:,2),mseVolaKalmanOut];
rmseVolaVARKalman = [rmse(:,2),rmseVolaKalmanOut];

[~, smallerMod] = min(mseVolaVARKalman');
bestModelVARKalman = mode(smallerMod);

% -> VAR(1)-model is better than the Kalman filter
