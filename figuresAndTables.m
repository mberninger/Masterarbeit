%% In this script I save all my figures and tables used in the master thesis document:

%% Theoretical background
% The volatility smile
load('impliedVolaCall.mat')
load('impliedVolaPut.mat')
test = data(data.IsCall == 1,:);
test.implVol = implVolCall;
test2 = test(test.Strike >=5000,:);

figure;
plot(test2.Strike(50:86),test2.implVol(50:86))
xlabel('Strike price')
ylabel('implied volatility')
grid on
grid minor
title('Volatility smile')

%% The data

% figure of Dax price index over the whole time frome June 2006 - Dec 2013
plot(data.Date, data.DAX);
datetick 'x'
grid on
grid minor
xlabel('Date')
ylabel('DAX index')

% figure to express the extreme values for small time to maturity values
% and small moneyness
load data;
load('impliedVolaCall.mat')
load('impliedVolaPut.mat')
dataCall = data(data.IsCall == 1,:);
dataCall.implVol = implVolCall;
dataCall.Moneyness = dataCall.Strike./dataCall.DAX;
dataPut = data(data.IsCall == 0,:);
dataPut.implVol = implVolPut;
dataPut.Moneyness = dataPut.Strike./dataPut.DAX;
dataTest = [dataCall;dataPut];
%Plot moneyness, time to maturity and implied volatility to see extreme
%values, choose day k, eg. day 750 for extreme small time
k=750;
[uniqueDatesAll, dataPerDayAll] = unique(dataTest.Date);
dayChangesAll = [dataPerDayAll; size(dataTest, 1)+1];
obsRange = dayChangesAll(k):dayChangesAll(k+1)-1;
figure;
scatter3(dataTest.Moneyness(obsRange),dataTest.TimeToMaturity(obsRange),dataTest.implVol(obsRange),'o');
view(-200,20);
xlabel('Moneyness')
ylabel('TimeToMaturity')
zlabel('implied volatility')
grid on
grid minor

%The same for the put options
dataPut = data(data.IsCall == 0,:);
dataPut.implVol = implVolPut;
dataPut.Moneyness = dataPut.Strike./dataPut.DAX;
% Plot moneyness, time to maturity and implied volatility to see extreme
%values, choose day k, eg day 500
k=750;
[uniqueDatesPutAll, dataPerDayPutAll] = unique(dataPut.Date);
dayChangesPutAll = [dataPerDayPutAll; size(dataPut, 1)+1];
figure;
obsRangePut = dayChangesPutAll(k):dayChangesPutAll(k+1)-1;
scatter3(dataPut.Moneyness(obsRangePut),dataPut.TimeToMaturity(obsRangePut),implVolPut(obsRangePut),'o');
view(-200,20);
xlabel('Moneyness')
ylabel('TimeToMaturity')
zlabel('implied volatility')
grid on
grid minor

% something missing!

% figure of the frequency of values for call options
dataCall = data(data.IsCall == 1,:);
dataCall.implVol = implVolCall;
dataCall.Moneyness = dataCall.Strike./dataCall.DAX;
% Moneyness, adaptions afterwards
histogram(dataCall.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of call options')
axis([0 4.5 0 inf]);
% Time to maturity, adaptions afterwards
histogram(dataCall.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of call options')
% Option prices, adaptions afterwards
histogram(dataCall.implVol)
grid on
grid minor
xlabel('Implied volatility')
ylabel('Number of call options')
axis([0 2 0 inf]);
% Option prices, adaptions afterwards
histogram(dataCall.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of call options')
axis([0 5000 0 inf]);

%The same histogramms for Put options
dataPut = data(data.IsCall == 0, :);
dataPut.Moneyness = dataPut.Strike./dataPut.DAX;
%Histogramm moneyness
histogram(dataPut.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of put options')
axis([0 4.5 0 inf]);
%Histogramm time to maturity
histogram(dataPut.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of put options')
% Histogram implied volatility
histogram(implVolPut)
grid on
grid minor
xlabel('Implied volatility')
ylabel('Number of put options')
axis([0 2 0 inf]);
% Option prices, adaptions afterwards
histogram(dataPut.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of put options')
axis([0 5000 0 inf]);



% ????????????????????
% observations per day:
obsPerDay = zeros(length(uniqueDates),1);
for ii = 1:length(uniqueDates)
    obsPerDay(ii,:) = dayChanges(ii+1)-dayChanges(ii);
end
figure
plot(obsPerDay);
hold on;
plot(mean(obsPerDay)*ones(length(uniqueDates),1));

obsPerDayPut = zeros(length(uniqueDatesPut),1);
for ii = 1:length(uniqueDatesPut)
    obsPerDayPut(ii,:) = dayChangesPut(ii+1)-dayChangesPut(ii);
end
figure
plot(obsPerDayPut);
hold on;
plot(mean(obsPerDayPut)*ones(length(uniqueDatesPut),1));
% number of observed maturities per day
maturityChanges = zeros(length(uniqueDates),1);
maturityChangesPut = zeros(length(uniqueDatesPut),1);
for j = 1:length(uniqueDates)
    uniqueMaturities = unique(filteredDataCall.TimeToMaturity(dayChanges(j):dayChanges(j+1)-1));
    uniqueMaturitiesPut = unique(filteredDataPut.TimeToMaturity(dayChangesPut(j):dayChangesPut(j+1)-1));
    maturityChanges(j) = length(uniqueMaturities);
    maturityChangesPut(j) = length(uniqueMaturitiesPut);
end
figure
plot(maturityChanges,'.');
figure
plot(maturityChangesPut,'.');
% number of observed strikes per day
strikeChanges = zeros(length(uniqueDates),1);
strikeChangesPut = zeros(length(uniqueDatesPut),1);
for j = 1:length(uniqueDates)
    uniqueStrikes = unique(filteredDataCall.Strike(dayChanges(j):dayChanges(j+1)-1));
    uniqueStrikesPut = unique(filteredDataPut.Strike(dayChangesPut(j):dayChangesPut(j+1)-1));
    strikeChanges(j) = length(uniqueStrikes);
    strikeChangesPut(j) = length(uniqueStrikesPut);
end
figure
plot(strikeChanges,'.');
figure
plot(strikeChangesPut,'.');

%% Fitting the implied volatility surface

% in-sample testing over all 5 models, evaluating R², adj R², MSE, RMSE and
% AIC in order to get best model
% include the rsquared calculation in the function getCoeff
model1 = [1,2];
[coeff1, rsquared1] = getCoeff(model1, filteredDataCall);
model2 = [1,3];
[coeff2, rsquared2] = getCoeff(model2, filteredDataCall);
model3 = [1,3,5];
[coeff3, rsquared3] = getCoeff(model3, filteredDataCall);
model4 = [1,2,3,5];
[coeff4, rsquared4] = getCoeff(model4, filteredDataCall);
model5 = [1,2,3,4,5];
[coeff5, rsquared5] = getCoeff(model5, filteredDataCall);

vola1 = evalVola(filteredDataCall, coeff1, model1 );
mse1 = getMse(vola1,filteredDataCall.implVol);
rmse1 = getRmse(vola1,filteredDataCall.implVol);
vola2 = evalVola(filteredDataCall, coeff2, model2 );
mse2 = getMse(vola2,filteredDataCall.implVol);
rmse2 = getRmse(vola2,filteredDataCall.implVol);
vola3 = evalVola(filteredDataCall, coeff3, model3 );
mse3 = getMse(vola3,filteredDataCall.implVol);
rmse3 = getRmse(vola3,filteredDataCall.implVol);
vola4 = evalVola(filteredDataCall, coeff4, model4 );
mse4 = getMse(vola4,filteredDataCall.implVol);
rmse4 = getRmse(vola4,filteredDataCall.implVol);
vola5 = evalVola(filteredDataCall, coeff5, model5 );
mse5 = getMse(vola5,filteredDataCall.implVol);
rmse5 = getRmse(vola5,filteredDataCall.implVol);

load('modelAICCallAndPut.mat');

model1Testing = mean(rsquared1)';
model2Testing = mean(rsquared2)';
model3Testing = mean(rsquared3)';
model4Testing = mean(rsquared4)';
model5Testing = mean(rsquared5)';

inSampleTesting1 = [model1Testing(1,1), model1Testing(2,1), mse1, rmse1, mean(modelAIC(:,1))]';
inSampleTesting2 = [model2Testing(1,1), model2Testing(2,1), mse2, rmse2, mean(modelAIC(:,2))]';
inSampleTesting3 = [model3Testing(1,1), model3Testing(2,1), mse3, rmse3, mean(modelAIC(:,3))]';
inSampleTesting4 = [model4Testing(1,1), model4Testing(2,1), mse4, rmse4, mean(modelAIC(:,4))]';
inSampleTesting5 = [model5Testing(1,1), model5Testing(2,1), mse5, rmse5, mean(modelAIC(:,5))]';

inSampleTesting = [inSampleTesting1, inSampleTesting2, inSampleTesting3, inSampleTesting4, inSampleTesting5];

% rowNames = {'R^2','adjustedR^2','MSE','RMSE','AIC'};
% columneNames = {'Model1', 'Model2', 'Model3', 'Model4', 'Model5'};
% 
% inSampleTest = table(inSampleTesting, 'VariableNames', columneNames, 'RowNames', rowNames);

%xlswrite('inSampleTesting.xls',inSampleTesting);


% to get out of sample tests over all 5 models evaluate mean, std dev, min
% and max of all MSE and RMSE values of all models
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
% xlswrite('outOfSampleTesting.xls',outOfSampleTesting);


% robustness tests:

% frequency of being best model only for one repetition!
nDates = length(uniqueDates);
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
freqOfBestModelFirst = [1:5;freqOfModMSE;freqOfModRMSE];
% xlswrite('freqOfBestModelBoth.xls',freqOfBestModel);


% repetion of out-of-sample test for 100 times:
nRep = 100;
nDates = length(uniqueDates);
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
freqOfBestModel = [1:5;freqOfModMSE;freqOfModRMSE];
% xlswrite('freqOfBestModelRep.xls',freqOfBestModel);

%% Modelling the Dynamics of the implied volatility surface
%% properties of the estimated coefficients:
% plot histogram of estimated coefficient
figure;
histogram(coeff(:,5));

% Kolmogorov-Smirnov test for standard normal distribution of coefficients:
val = coeff(1500:end,5);
mu = mean(val);
sigma = std(val);
x = (val-mu)/sigma;
[h,pvalue] = kstest(x);

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

% partial autocorrelation functions for the coefficients:
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

%% IN-SAMPLE:
% AR(5) model:
% are residuals of coeff and param normally distributed??
param = getParamAR5(coeff, 5);
    residual = coeff-param;
    val = residual(:,1);
    mu = mean(residual(:,1));
    sigma = std(residual(:,1));
    [H,P] = kstest((val-mu)/sigma);


