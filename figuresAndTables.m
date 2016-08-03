%% In this script I save all my figures and tables used in the master thesis document:

%% Theoretical background
% Figure 3.4: The volatility smile
load('impliedVolaCall.mat')
dataCall = data(data.IsCall == 1,:);
dataCall.implVol = implVolCall;
dataCallFiltered = dataCall(dataCall.Strike >=5000,:);

figure;
plot(dataCallFiltered.Strike(50:86),dataCallFiltered.implVol(50:86))
xlabel('Strike price')
ylabel('implied volatility')
grid on
grid minor
title('Volatility smile')

%% The data
% Figure 4.1: Dax price index over the whole time from June 2006 - Dec 2013
plot(data.Date, data.DAX);
datetick 'x'
grid on
grid minor
xlabel('Date')
ylabel('DAX index')


% histograms for frequency of variables for call options
dataCall = data(data.IsCall == 1,:);
load('impliedVolaCall.mat')
dataCall.implVol = implVolCall;
dataCall.Moneyness = dataCall.Strike./dataCall.DAX;
% Figure 4.2: histogram option prices
histogram(dataCall.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of call options')
axis([0 5000 0 inf]);
% Figure 4.3: histogram time to maturity
histogram(dataCall.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of call options')
% Figure 4.4: histogram moneyness
histogram(dataCall.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of call options')
axis([0 4.5 0 inf]);
% Figure 4.5: histogram implied volatilities
histogram(dataCall.implVol)
grid on
grid minor
xlabel('Implied volatility')
ylabel('Number of call options')
axis([0 2 0 inf]);

% the same histograms for put options
dataPut = data(data.IsCall == 0, :);
load('impliedVolaPut.mat')
dataPut.implVol = implVolPut;
dataPut.Moneyness = dataPut.Strike./dataPut.DAX;
% Figure 4.2: histogram option prices
histogram(dataPut.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of put options')
axis([0 5000 0 inf]);
% Figure 4.3: histogram time to maturity
histogram(dataPut.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of put options')
% Figure 4.4: Histogramm moneyness
histogram(dataPut.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of put options')
axis([0 4.5 0 inf]);
% Figure 4.5: histogram implied volatility
histogram(dataPut.implVol)
grid on
grid minor
xlabel('Implied volatility')
ylabel('Number of put options')
axis([0 2 0 inf]);


% Figure 4.6: express the extreme values for small  and high time to maturity
% values and small and high moneyness
load data;
load('impliedVolaCall.mat')
load('impliedVolaPut.mat')
dataCall = data(data.IsCall == 1,:);
dataCall.implVol = implVolCall;
dataCall.Moneyness = dataCall.Strike./dataCall.DAX;
dataPut = data(data.IsCall == 0,:);
dataPut.implVol = implVolPut;
dataPut.Moneyness = dataPut.Strike./dataPut.DAX;
dataAll = [dataCall;dataPut];
dataAll = sortrows(dataAll,'Date','ascend');
%Plot moneyness, time to maturity and implied volatility to see extreme
%values, choose day k, eg. day 750
k=750;
[~, dataPerDayAll] = unique(dataAll.Date);
dayChangesAll = [dataPerDayAll; size(dataAll, 1)+1];
obsRange = dayChangesAll(k):dayChangesAll(k+1)-1;
figure;
scatter3(dataAll.Moneyness(obsRange),dataAll.TimeToMaturity(obsRange),dataAll.implVol(obsRange),'o');
view(-200,20);
xlabel('Moneyness')
ylabel('TimeToMaturity')
zlabel('implied volatility')
grid on
grid minor

clear dataAll dataCall dataPut dataCallFiltered dataPerDayAll dayChangesAll implVolCall implVolPut k obsRange uniqueDatesAll

%% Fitting the implied volatility surfaces
%% in-sample test:
% Table 5.1: in-sample test for all 5 models, evaluating the mean of R², the mean of
% adj R², MSE, RMSE and the mean of the AIC in order to get best model
    % see Main function, -> FITTING THE IMPLIED VOLATILITY SURFACES 
    % for call and put options -> IN SAMPLE TESTING for the required table

%% out-of-sample test
% Table 5.2: out of sample tests for all 5 models: evaluate mean, standard deviation,
% minimum and maximum of all MSE and RMSE values of all models
load('mseOutOfSampleCallAndPut.mat')
load('rmseOutOfSampleCallAndPut.mat')
mod1 = reshape(mseOutOfSample(1,1,:),[1,1908])';
mod2 = reshape(mseOutOfSample(1,2,:),[1,1908])';
mod3 = reshape(mseOutOfSample(1,3,:),[1,1908])';
mod4 = reshape(mseOutOfSample(1,4,:),[1,1908])';
mod5 = reshape(mseOutOfSample(1,5,:),[1,1908])';

modR1 = reshape(rmseOutOfSample(1,1,:),[1,1908])';
modR2 = reshape(rmseOutOfSample(1,2,:),[1,1908])';
modR3 = reshape(rmseOutOfSample(1,3,:),[1,1908])';
modR4 = reshape(rmseOutOfSample(1,4,:),[1,1908])';
modR5 = reshape(rmseOutOfSample(1,5,:),[1,1908])';

outOfSampleTesting = [mean(mod1),std(mod1),min(mod1),max(mod1);
mean(modR1),std(modR1),min(modR1),max(modR1);
mean(mod2),std(mod2),min(mod2),max(mod2);
mean(modR2),std(modR2),min(modR2),max(modR2);
mean(mod3),std(mod3),min(mod3),max(mod3);
mean(modR3),std(modR3),min(modR3),max(modR3);
mean(mod4),std(mod4),min(mod4),max(mod4);
mean(modR4),std(modR4),min(modR4),max(modR4);
mean(mod5),std(mod5),min(mod5),max(mod5);
mean(modR5),std(modR5),min(modR5),max(modR5)];

outOfSampleTesting = table(outOfSampleTesting(:,1),outOfSampleTesting(:,2),outOfSampleTesting(:,3),outOfSampleTesting(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'Mod1_MSE';'Mod1RMSE';'Mod2_MSE';'Mod2RMSE';'Mod3_MSE';'Mod3RMSE';'Mod4_MSE';'Mod4RMSE';'Mod5_MSE';'Mod5RMSE'});

clear mod1 mod2 mod3 mod4 mod5 modR1 modR2 modR3 modR4 modR5 clear mseOutOfSample rmseOutOfSample

%% robustness tests:
% Table 5.3: frequency of being best model only for one repetition!
nDates = size(unique(data.Date),1);
indexMSE = zeros(nDates,1);
indexRMSE = zeros(nDates,1);

load('mseOutOfSampleCallAndPut.mat')
load('rmseOutOfSampleCallAndPut.mat')

mseOutOfSampleFirst = mseOutOfSample(1,:,:);
rmseOutOfSampleFirst = rmseOutOfSample(1,:,:);

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mseOutOfSampleFirst(:,:,ii).');
    [ ~ , indexRMSE(ii,:)] = min(rmseOutOfSampleFirst(:,:,ii).');
end

[~, modelChange] = unique(sort(indexMSE(:,1)));
freqOfModMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),modelChange(4)-modelChange(3),modelChange(5)-modelChange(4),length(indexMSE)+1-modelChange(5)];
[~, modelChangeR] = unique(sort(indexRMSE(:,1)));
freqOfModRMSE = [modelChangeR(2)-modelChangeR(1),modelChangeR(3)-modelChangeR(2),modelChangeR(4)-modelChangeR(3),modelChangeR(5)-modelChangeR(4),length(indexRMSE)+1-modelChangeR(5)];
freqOfBestModelFirst = [freqOfModMSE;freqOfModRMSE];
freqOfBestModelFirst = table(freqOfBestModelFirst(:,1),freqOfBestModelFirst(:,2),freqOfBestModelFirst(:,3),freqOfBestModelFirst(:,4),freqOfBestModelFirst(:,5),'VariableNames',{'Model_1','Model_2','Model_3','Model_4','Model_5'},'RowNames',{'MSE_Frequency';'RMSE_Frequency'});

clear ii indexMSE indexRMSE modelChange modelChangeR nDates 
clear mseOutOfSample mseOutOfSampleFirst rmseOutOfSample rmseOutOfSampleFirst
clear freqOfModMSE freqOfModRMSE

% Table 5.4: repetion of out-of-sample test for 100 times:
nRep = 100;
nDates = size(unique(data.Date),1);
indexMSE = zeros(nDates,nRep);
indexRMSE = zeros(nDates,nRep);
bestModelForDayMSE = zeros(nDates,1);
bestModelForDayRMSE = zeros(nDates,1);

load('mseOutOfSampleCallAndPut.mat')
load('rmseOutOfSampleCallAndPut.mat')

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mseOutOfSample(:,:,ii).');
    [ ~ , indexRMSE(ii,:)] = min(rmseOutOfSample(:,:,ii).');
    bestModelForDayMSE(ii) = mode(indexMSE(ii,:));
    bestModelForDayRMSE(ii) = mode(indexRMSE(ii,:));
end

[~, modelChange] = unique(sort(bestModelForDayMSE));
freqOfModMSE = [modelChange(2)-modelChange(1),0,modelChange(3)-modelChange(2),modelChange(4)-modelChange(3),length(indexMSE)+1-modelChange(4)];
[~, modelChangeR] = unique(sort(bestModelForDayRMSE));
freqOfModRMSE = [modelChangeR(2)-modelChangeR(1),0,modelChangeR(3)-modelChangeR(2),modelChangeR(4)-modelChangeR(3),length(indexRMSE)+1-modelChangeR(4)];
freqOfBestModel = [freqOfModMSE;freqOfModRMSE];
freqOfBestModel = table(freqOfBestModel(:,1),freqOfBestModel(:,2),freqOfBestModel(:,3),freqOfBestModel(:,4),freqOfBestModel(:,5),'VariableNames',{'Model_1','Model_2','Model_3','Model_4','Model_5'},'RowNames',{'MSE_Frequency_100Rep';'RMSE_Frequency_100Rep'});

clear bestModelForDayMSE bestModelForDayRMSE freqOfModMSE freqOfModRMSE ii indexMSE indexRMSE
clear modelChange modelChangeR mseOutOfSample nRep rmseOutOfSample nDates


% Table 5.5: two new filter are used to test the previous results, the mse and rmse
% are calculated out-of-sample and are loaded here:
    % enlarged dataset mse and rmse values, out-of-sample:
    load('mseOutOfSampleCallAndPutFewerFilter.mat')
    load('rmseOutOfSampleCallAndPutFewerFilter.mat')
    % the mean of the mse and the rmse are considered, only for the first
    % value
mod1 = reshape(mseOutOfSample(1,1,:),[1,1908])';
mod2 = reshape(mseOutOfSample(1,2,:),[1,1908])';
mod3 = reshape(mseOutOfSample(1,3,:),[1,1908])';
mod4 = reshape(mseOutOfSample(1,4,:),[1,1908])';
mod5 = reshape(mseOutOfSample(1,5,:),[1,1908])';

modR1 = reshape(rmseOutOfSample(1,1,:),[1,1908])';
modR2 = reshape(rmseOutOfSample(1,2,:),[1,1908])';
modR3 = reshape(rmseOutOfSample(1,3,:),[1,1908])';
modR4 = reshape(rmseOutOfSample(1,4,:),[1,1908])';
modR5 = reshape(rmseOutOfSample(1,5,:),[1,1908])';

outOfSampleTestingEnlargedData = [mean(mod1), mean(mod2), mean(mod3), mean(mod4), mean(mod5);
    mean(modR1), mean(modR2), mean(modR3), mean(modR4), mean(modR5)];

outOfSampleTestingEnlargedData = table(outOfSampleTestingEnlargedData(:,1),outOfSampleTestingEnlargedData(:,2),outOfSampleTestingEnlargedData(:,3),outOfSampleTestingEnlargedData(:,4),outOfSampleTestingEnlargedData(:,5),'VariableNames',{'Model_1';'Model_2';'Model_3';'Model_4';'Model_5'},'RowNames',{'mean_MSE';'mean_RMSE'});

clear mod1 mod2 mod3 mod4 mod5 modR1 modR2 modR3 modR4 modR5 mseOutOfSample rmseOutOfSample

% Table 5.6: second different filter:
    % diminished dataset mse and rmse values, out-of-sample:
    load('mseOutOfSampleCallAndPutSmaller.mat')
    load('rmseOutOfSampleCallAndPutSmaller.mat')
    % the mean of the mse and the rmse are considered, only for the first
    % value
mod1 = reshape(mseOutOfSample(1,1,:),[1,1908])';
mod2 = reshape(mseOutOfSample(1,2,:),[1,1908])';
mod3 = reshape(mseOutOfSample(1,3,:),[1,1908])';
mod4 = reshape(mseOutOfSample(1,4,:),[1,1908])';
mod5 = reshape(mseOutOfSample(1,5,:),[1,1908])';

modR1 = reshape(rmseOutOfSample(1,1,:),[1,1908])';
modR2 = reshape(rmseOutOfSample(1,2,:),[1,1908])';
modR3 = reshape(rmseOutOfSample(1,3,:),[1,1908])';
modR4 = reshape(rmseOutOfSample(1,4,:),[1,1908])';
modR5 = reshape(rmseOutOfSample(1,5,:),[1,1908])';

outOfSampleTestingDiminishedData = [mean(mod1), mean(mod2), mean(mod3), mean(mod4), mean(mod5);
    mean(modR1), mean(modR2), mean(modR3), mean(modR4), mean(modR5)];

outOfSampleTestingDiminishedData = table(outOfSampleTestingDiminishedData(:,1),outOfSampleTestingDiminishedData(:,2),outOfSampleTestingDiminishedData(:,3),outOfSampleTestingDiminishedData(:,4),outOfSampleTestingDiminishedData(:,5),'VariableNames',{'Model_1';'Model_2';'Model_3';'Model_4';'Model_5'},'RowNames',{'mean_MSE';'mean_RMSE'});

clear mod1 mod2 mod3 mod4 mod5 modR1 modR2 modR3 modR4 modR5 mseOutOfSample rmseOutOfSample

    

% Figure 5.1: plot volatility surfaces for exemplary days, using model 3, 4 and 5
% three different days are chosen: one, where model 3 performs best (day
% 524), one, where model 4 performs best (day 20) and one, where model 5
% performs best (day 97)
    % first calculated coefficients for different models:
model3 = [1,3,5];
coeff3 = getCoeff(model3, filteredData);
model4 = [1,2,3,5];
coeff4 = getCoeff(model4, filteredData);
model5 = [1,2,3,4,5];
coeff5 = getCoeff(model5, filteredData);
    % the variable dayChanges is needed in the function for plotting the
    % volatility surface
[~, dataPerDay] = unique(filteredData.Date);
dayChanges = [dataPerDay; size(filteredData, 1)+1];
    % now the volatility surfaces are plotted for chosen day
day = 97; % or 20 or 524
plotSurface(day,coeff3,model3,filteredData,dayChanges);
plotSurface(day,coeff4,model4,filteredData,dayChanges);
plotSurface(day,coeff5,model5,filteredData,dayChanges);
    
clear coeff3 coeff4 coeff5 dataPerDay day dayChanges model3 model4 model5 uniqueDates

%% Delete variables after this chapter:
clear freqOfBestModel freqOfBestModelFirst inSampleTesting outOfSampleTesting outOfSampleTestingDiminishedData outOfSampleTestingEnlargedData
%% Modelling the Dynamic of the implied volatility surfaces
%% properties of the estimated coefficients:
% model = [1,2,3,4,5];
% coeff = getCoeff(model, filteredData);
load('coeff.mat')
uniqueDates = unique(filteredData.Date);
% Figure 6.1: plot coefficients of the model over time -> not constant, but time
% dependent:
figure;
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('level','slope moneyness','curvature moneyness','slope time to maturity','curvature time to maturity','slope cross-product term','Location','southwest')
title('Model coefficients')
xlabel('Date')
ylabel('value of coefficients')

% Table 6.1: correlation of coefficients
depOfCoeff = corr(coeff);

% Figure 6.2: partial autocorrelation functions for the coefficients:
figure;
parcorr(coeff(:,1),50);
figure;
parcorr(coeff(:,2),50);
figure;
parcorr(coeff(:,3),50);
figure;
parcorr(coeff(:,4),50);
figure;
parcorr(coeff(:,5),50);
figure;
parcorr(coeff(:,6),50);

%% in-sample test:
% Table 6.2: BIC for different lags and different coefficients for AR-model
load('coeff.mat')
bicAR = zeros(5,size(coeff,2));
for ii = 1:5
    [~, ~, bicAR(ii,:)] = getPredCoeffAR(coeff,ones(1,6)*ii);    
end

% Table 6.3: BIC for different lags and different coefficients for VAR-model
bicVAR = zeros(5,1);
for ii = 1:5
    [~,bicVAR(ii,:)] = getPredCoeffVAR(coeff, ii);
end

% Table 6.4: comparison of different models: see Main function: modelling the dynamics
%of the implied volatilites: in-sample tests
clear ii
%% out-of-sample test:
% Table 6.5: get best number of lags for AR model
% [bestModelAROut,bestModelVAROut] = getBestLagNb( filteredData, coeff, uniqueDates, nRep, timeWindow);
load('bestModelAROut6years.mat')
[~, modelChange] = unique(sort(bestModelAROut(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),modelChange(4)-modelChange(3),modelChange(5)-modelChange(4),length(bestModelAROut)+1-modelChange(5)];
freqOfBestModelDynamicARLag = table(freqBestMSE(:,1),freqBestMSE(:,2),freqBestMSE(:,3),freqBestMSE(:,4),freqBestMSE(:,5),'VariableNames',{'Lag1','Lag2','Lag3','Lag4','Lag5'},'RowNames',{'Frequency'});

clear modelChange bestModelAROut freqBestMSE

% Table 6.6: get best number of lags for VAR model
load('bestModelVAROut6years.mat')
[~, modelChange] = unique(sort(bestModelVAROut(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),modelChange(4)-modelChange(3),modelChange(5)-modelChange(4),length(bestModelVAROut)+1-modelChange(5)];
freqOfBestModelDynamicVARLag = table(freqBestMSE(:,1),freqBestMSE(:,2),freqBestMSE(:,3),freqBestMSE(:,4),freqBestMSE(:,5),'VariableNames',{'Lag1','Lag2','Lag3','Lag4','Lag5'},'RowNames',{'Frequency'});

clear bestModelVAROut modelChange freqBestMse

% Table 6.7: comparison of different models 
load('mseVolaAllMod6yearsOutNew.mat')
load('rmseVolaAllMod6yearsOutNew.mat')
outOfSampleDynamic = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3))];
outOfSampleDynamic = table(outOfSampleDynamic(:,1),outOfSampleDynamic(:,2),outOfSampleDynamic(:,3),outOfSampleDynamic(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE'});

clear mse rmse 

%% robustness tests:
% Table 6.8: different time window: 3 years 
load('mseVolaAllMod3yearsOutNew.mat')
load('rmseVolaAllMod3yearsOutNew.mat')
outOfSampleShorter = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3))];

outOfSampleShorter = table(outOfSampleShorter(:,1),outOfSampleShorter(:,2),outOfSampleShorter(:,3),outOfSampleShorter(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE'});

clear mse rmse

%% Summary:
% Figure 6.3: plot coeff and via VAR(1)-model estimated coefficients
load('coeff.mat')
predCoeffVAR = getPredCoeffVAR(coeff, 1);
figure;
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('level','slope moneyness','curvature moneyness','slope time to maturity','curvature time to maturity','slope cross-product term','Location','southwest')
title('Model coefficients')
xlabel('Date')
ylabel('value of coefficients')
hold on
plot(uniqueDates, predCoeffVAR)
hold off


%% APPLICATION OF THE KALMAN FILTER:
%% in-sample test:
% Figure 7.1: Course of the coefficients and estimated coefficients via Kalman
load('coeff.mat')
model = [1,2,3,4,5];
vola = evalVola(filteredData, coeff, model);
coeffKalman = getPredCoeffKalman(coeff,uniqueDates,filteredData,vola);
figure;
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('level','slope moneyness','curvature moneyness','slope time to maturity','curvature time to maturity','slope cross-product term','Location','southwest')
title('Model coefficients')
xlabel('Date')
ylabel('value of coefficients')
hold on
plot(uniqueDates, coeffKalman)
hold off

%% out-of-sample test:
% Table 7.1: MSE and RMSE values of different models and Kalman filter, 6
% years time window, 100 repetitions
load('mseVolaAllMod6yearsOutNew.mat')
load('rmseVolaAllMod6yearsOutNew.mat')
load('mseVolaKalman6yearsOutNew.mat')
load('rmseVolaKalman6yearsOutNew.mat')

outOfSampleAllKalman = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3));
    mean(mseVolaKalmanOut(:,1)),std(mseVolaKalmanOut(:,1)), min(mseVolaKalmanOut(:,1)),max(mseVolaKalmanOut(:,1));
    mean(rmseVolaKalmanOut(:,1)),std(rmseVolaKalmanOut(:,1)), min(rmseVolaKalmanOut(:,1)),max(rmseVolaKalmanOut(:,1));];
outOfSampleAllKalman = table(outOfSampleAllKalman(:,1),outOfSampleAllKalman(:,2),outOfSampleAllKalman(:,3),outOfSampleAllKalman(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE';'Kalman_MSE';'Kalman_RMSE'});

%% robustness test:
% Table 7.2: frequency of being the best model, 6 years, 100 rep
nDates = 100;
indexMSE = zeros(nDates,1);
indexRMSE = zeros(nDates,1);

load('mseVolaAllMod6yearsOutNew.mat')
load('rmseVolaAllMod6yearsOutNew.mat')
load('mseVolaKalman6yearsOutNew.mat')
load('rmseVolaKalman6yearsOutNew.mat')

% mseAllKalman = [mse, mseVolaKalmanOut];
% rmseAllKalman = [rmse, rmseVolaKalmanOut];

mseAllKalman = [mse(:,2), mseVolaKalmanOut];
rmseAllKalman = [rmse(:,2), rmseVolaKalmanOut];

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mseAllKalman(ii,:));
    [ ~ , indexRMSE(ii,:)] = min(rmseAllKalman(ii,:));
end

[~, modelChange] = unique(sort(indexMSE(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),length(indexMSE)+1-modelChange(2)];
[~, modelChangeR] = unique(sort(indexRMSE(:,1)));
freqBestRMSE = [modelChangeR(2)-modelChangeR(1),length(indexRMSE)+1-modelChangeR(2)];
freqOfBestModelDynamic6years = [freqBestMSE;freqBestRMSE];
freqOfBestModelDynamic6years = table(freqOfBestModelDynamic6years(:,1),freqOfBestModelDynamic6years(:,2),'VariableNames',{'VAR_model','Kalman_filter'},'RowNames',{'MSE_Frequency';'RMSE_Frequency'});

clear mseAllKalman rmseAllKalman nDates indexMSE indexRMSE modelChange modelChangeR freqBestMSE freqBestRMSE mse rmse mseVolaKalmanOut rmseVolaKalmanOut ii

% three years time window:
load('mseVolaAllMod3yearsOutNew.mat')
load('rmseVolaAllMod3yearsOutNew.mat')
load('mseVolaKalman3yearsOutNew.mat')
load('rmseVolaKalman3yearsOutNew.mat')

outOfSampleAllKalman3years = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3));
    mean(mseVolaKalmanOut(:,1)),std(mseVolaKalmanOut(:,1)), min(mseVolaKalmanOut(:,1)),max(mseVolaKalmanOut(:,1));
    mean(rmseVolaKalmanOut(:,1)),std(rmseVolaKalmanOut(:,1)), min(rmseVolaKalmanOut(:,1)),max(rmseVolaKalmanOut(:,1));];
outOfSampleAllKalman3years = table(outOfSampleAllKalman3years(:,1),outOfSampleAllKalman3years(:,2),outOfSampleAllKalman3years(:,3),outOfSampleAllKalman3years(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE';'Kalman_MSE';'Kalman_RMSE'});

clear mse rmse mseVolaKalmanOut rmseVolaKalmanOut

% frequency of being the best model, 3 years, 100 rep
nDates = 100;
indexMSE = zeros(nDates,1);
indexRMSE = zeros(nDates,1);

load('mseVolaAllMod3yearsOutNew.mat')
load('rmseVolaAllMod3yearsOutNew.mat')
load('mseVolaKalman3yearsOutNew.mat')
load('rmseVolaKalman3yearsOutNew.mat')

mseAllKalman = [mse(:,2), mseVolaKalmanOut];
rmseAllKalman = [rmse(:,2), rmseVolaKalmanOut];

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mseAllKalman(ii,:));
    [ ~ , indexRMSE(ii,:)] = min(rmseAllKalman(ii,:));
end

[~, modelChange] = unique(sort(indexMSE(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),length(indexMSE)+1-modelChange(2)];
[~, modelChangeR] = unique(sort(indexRMSE(:,1)));
freqBestRMSE = [modelChangeR(2)-modelChangeR(1),length(indexRMSE)+1-modelChangeR(2)];
freqOfBestModelDynamic3years = [freqBestMSE;freqBestRMSE];
freqOfBestModelDynamic3years = table(freqOfBestModelDynamic3years(:,1),freqOfBestModelDynamic3years(:,2),'VariableNames',{'VAR_model','Kalman_filter'},'RowNames',{'MSE_Frequency';'RMSE_Frequency'});

clear mseAllKalman rmseAllKalman nDates indexMSE indexRMSE modelChange modelChangeR freqBestMSE freqBestRMSE mse rmse mseVolaKalmanOut rmseVolaKalmanOut ii

