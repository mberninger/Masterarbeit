%% In this script I save all my figures and tables used in the master thesis document:

%% Theoretical background
% The volatility smile
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
% figure of Dax price index over the whole time from June 2006 - Dec 2013
plot(data.Date, data.DAX);
datetick 'x'
grid on
grid minor
xlabel('Date')
ylabel('DAX index')


% histogram for frequency of variables for call options
dataCall = data(data.IsCall == 1,:);
load('impliedVolaCall.mat')
dataCall.implVol = implVolCall;
dataCall.Moneyness = dataCall.Strike./dataCall.DAX;
% histogram option prices
histogram(dataCall.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of call options')
axis([0 5000 0 inf]);
% histogram time to maturity
histogram(dataCall.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of call options')
% histogram moneyness
histogram(dataCall.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of call options')
axis([0 4.5 0 inf]);
% histogram implied volatilities
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
% histogram option prices
histogram(dataPut.OptionPrice)
grid on
grid minor
xlabel('Option price')
ylabel('Number of put options')
axis([0 5000 0 inf]);
% Histogram time to maturity
histogram(dataPut.TimeToMaturity)
grid on
grid minor
xlabel('Time to maturity')
ylabel('Number of put options')
% Histogramm moneyness
histogram(dataPut.Moneyness)
grid on
grid minor
xlabel('Moneyness')
ylabel('Number of put options')
axis([0 4.5 0 inf]);
% Histogram implied volatility
histogram(dataPut.implVol)
grid on
grid minor
xlabel('Implied volatility')
ylabel('Number of put options')
axis([0 2 0 inf]);


% figure to express the extreme values for small  and high time to maturity
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
[uniqueDatesAll, dataPerDayAll] = unique(dataAll.Date);
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

%% Fitting the implied volatility surface
%% in-sample test:
% in-sample test for all 5 models, evaluating the mean of R², the mean of
% adj R², MSE, RMSE and the mean of the AIC in order to get best model
model1 = [1,2];
[coeff1, rsquared1] = getCoeff(model1, filteredData);
model2 = [1,3];
[coeff2, rsquared2] = getCoeff(model2, filteredData);
model3 = [1,3,5];
[coeff3, rsquared3] = getCoeff(model3, filteredData);
model4 = [1,2,3,5];
[coeff4, rsquared4] = getCoeff(model4, filteredData);
model5 = [1,2,3,4,5];
[coeff5, rsquared5] = getCoeff(model5, filteredData);

vola1 = evalVola(filteredData, coeff1, model1 );
mse1 = getMse(vola1,filteredData.implVol);
rmse1 = getRmse(vola1,filteredData.implVol);
vola2 = evalVola(filteredData, coeff2, model2 );
mse2 = getMse(vola2,filteredData.implVol);
rmse2 = getRmse(vola2,filteredData.implVol);
vola3 = evalVola(filteredData, coeff3, model3 );
mse3 = getMse(vola3,filteredData.implVol);
rmse3 = getRmse(vola3,filteredData.implVol);
vola4 = evalVola(filteredData, coeff4, model4 );
mse4 = getMse(vola4,filteredData.implVol);
rmse4 = getRmse(vola4,filteredData.implVol);
vola5 = evalVola(filteredData, coeff5, model5 );
mse5 = getMse(vola5,filteredData.implVol);
rmse5 = getRmse(vola5,filteredData.implVol);

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
inSampleTesting = table(inSampleTesting(:,1),inSampleTesting(:,2),inSampleTesting(:,3),inSampleTesting(:,4),inSampleTesting(:,5),'VariableNames',{'Model1','Model2','Model3','Model4', 'Model5'},'RowNames',{'R^2';'AdjR^2';'MSE';'RMSE';'AIC'});

clear inSampleTesting1 inSampleTesting2 inSampleTesting3 inSampleTesting4 inSampleTesting5 
clear model1Testing model2Testing model3Testing model4Testing model5Testing 
clear mse1 mse2 mse3 mse4 mse5 rmse1 rmse2 rmse3 rmse4 rmse5 vola1 vola2 vola3 vola4 vola5
clear model1 model2 model3 model4 model5 coeff1 coeff2 coeff3 coeff4 coeff5
clear rsquared1 rsquared2 rsquared3 rsquared4 rsquared5 modelAIC

%% out-of-sample test
% out of sample tests for all 5 models: evaluate mean, standard deviation,
% minnimum and maximum of all MSE and RMSE values of all models
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

clear mod1 mod2 mod3 mod4 mod5 modR1 modR2 modR3 modR4 modR5

%% robustness tests:
% frequency of being best model only for one repetition!
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

% repetion of out-of-sample test for 100 times:
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


% two new filter are used to test the previous results, the mse and rmse
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

% second different filter:
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

    

% plot volatility surfaces for exemplary days, using model 3, 4 and 5
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

%% Modelling the Dynamics of the implied volatility surface
%% properties of the estimated coefficients:
model = [1,2,3,4,5];
coeff = getCoeff(model, filteredData);
uniqueDates = unique(filteredData.Date);
% plot coefficients of the model over time -> not constant, but time
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

% correlation of coefficients
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

%% in-sample test:
% BIC for different lags and different coefficients for AR-model
bicAR = zeros(5,size(coeff,2));
for ii = 1:5
    [~, ~, bicAR(ii,:)] = getPredCoeffAR(coeff,ii);    
end

% BIC for different lags and different coefficients for VAR-model
bicVAR = zeros(5,1);
for ii = 1:5
    [~,bicVAR(ii,:)] = getPredCoeffVAR(coeff, ii);
end

%% out-of-sample test:
% get best number of lags for AR model
load('coeffOut6years');
mseVolaAROut = zeros(5,1);
rmseVolaAROut = zeros(5,1);
    for ii = 1:5;
        predCoeffAROut = getPredCoeffAROut(coeffOut, 1, ii);
            
        thisDate = uniqueDates(startDay);
        thisObs = getObs(thisDate,filteredData);
    
        volaAR = evalVola(thisObs,predCoeffAROut(1,:),model);
        mseVolaAROut(ii,1) = getMse(volaAR,thisObs.implVol);
        rmseVolaAROut(ii,1) = getRmse(volaAR,thisObs.implVol);
    end
bestLagAROut = table(mseVolaAROut, rmseVolaAROut, 'VariableNames',{'MSE','RMSE'}, 'RowNames',{'lag1';'lag2';'lag3';'lag4';'lag5'});
clear mse rmse ii predCoeffAROut thisDate thisObs volaAR mseVolaAROut rmseVolaAROut

% get best number of lags for VAR model
mseVolaVAROut = zeros(5,1);
rmseVolaVAROut = zeros(5,1);
for ii = 1:5
    predCoeffVAROut = getPredCoeffVAROut(coeffOut,1,ii);
    thisDate = uniqueDates(startDay);
    thisObs = getObs(thisDate,filteredDataCall);
    volaVAROut = evalVola(thisObs, predCoeffVAROut(1,:), model);
    mseVolaVAROut(ii,1) = getMse(thisObs.implVol,volaVAROut);
    rmseVolaVAROut(ii,1) = getRmse(thisObs.implVol,volaVAROut);
end
bestLagVAROut = table(mseVolaVAROut, rmseVolaVAROut, 'VariableNames',{'MSE','RMSE'}, 'RowNames',{'lag1';'lag2';'lag3';'lag4';'lag5'});
clear mse rmse ii predCoeffVAROut thisDate thisObs volaVAROut mseVolaVAROut rmseVolaVAROut coeffOut

% comparison of different models 
load('mseVolaAllMod6yearsOut.mat')
load('rmseVolaAllMod6yearsOut.mat')
bestCompModel = [mse(1,:)',rmse(1,:)'];
bestCompModel = table(bestCompModel(:,1),bestCompModel(:,2),'VariableNames',{'MSE','RMSE'},'RowNames',{'AR(1)_model';'VAR(3)_model';'comparison_model'});
clear mse rmse

%% robustness tests:
% frequency of being best model
nDates = 100;
indexMSE = zeros(nDates,1);
indexRMSE = zeros(nDates,1);

load('mseVolaAllMod6yearsOut.mat')
load('rmseVolaAllMod6yearsOut.mat')

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mse(ii,:));
    [ ~ , indexRMSE(ii,:)] = min(rmse(ii,:));
end

[~, modelChange] = unique(sort(indexMSE(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),length(indexMSE)+1-modelChange(3)];
[~, modelChangeR] = unique(sort(indexRMSE(:,1)));
freqBestRMSE = [modelChangeR(2)-modelChangeR(1),modelChangeR(3)-modelChangeR(2),length(indexRMSE)+1-modelChangeR(3)];
freqOfBestModelDynamic = [freqBestMSE;freqBestRMSE];
freqOfBestModelDynamic = table(freqOfBestModelDynamic(:,1),freqOfBestModelDynamic(:,2),freqOfBestModelDynamic(:,3),'VariableNames',{'AR_model','VAR_model','Comparing_model'},'RowNames',{'MSE_Frequency';'RMSE_Frequency'});

clear ii indexMSE indexRMSE modelChange modelChangeR nDates 
clear mse rmse freqBestMSE freqBestRMSE

% repetition of out-of-sample test 100 times
load('mseVolaAllMod6yearsOut.mat')
load('rmseVolaAllMod6yearsOut.mat')
outOfSampleDynamic = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3))];
outOfSampleDynamic = table(outOfSampleDynamic(:,1),outOfSampleDynamic(:,2),outOfSampleDynamic(:,3),outOfSampleDynamic(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE'});


% different time window: 3 years 
load('mseVolaAllMod3yearsOut.mat')
load('rmseVolaAllMod3yearsOut.mat')
outOfSampleShorter = [mean(mse(:,1)),std(mse(:,1)), min(mse(:,1)),max(mse(:,1));
    mean(rmse(:,1)),std(rmse(:,1)), min(rmse(:,1)),max(rmse(:,1));
    mean(mse(:,2)),std(mse(:,2)), min(mse(:,2)),max(mse(:,2));
    mean(rmse(:,2)),std(rmse(:,2)), min(rmse(:,2)),max(rmse(:,2));
    mean(mse(:,3)),std(mse(:,3)), min(mse(:,3)),max(mse(:,3));
    mean(rmse(:,3)),std(rmse(:,3)), min(rmse(:,3)),max(rmse(:,3))];

outOfSampleShorter = table(outOfSampleShorter(:,1),outOfSampleShorter(:,2),outOfSampleShorter(:,3),outOfSampleShorter(:,4),'VariableNames',{'mean', 'standardDeviation','minimum','maximum'},'RowNames',{'AR_Mod_MSE';'AR_Mod_RMSE';'VAR_Mod_MSE';'VAR_Mod_RMSE';'Comp_Mod_MSE';'Comp_Mod_RMSE'});

% frequency of being best for smaller time window of 3 years
nDates = 100;
indexMSE = zeros(nDates,1);
indexRMSE = zeros(nDates,1);
for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(mse(ii,:));
    [ ~ , indexRMSE(ii,:)] = min(rmse(ii,:));
end

[~, modelChange] = unique(sort(indexMSE(:,1)));
freqBestMSE = [modelChange(2)-modelChange(1),modelChange(3)-modelChange(2),length(indexMSE)+1-modelChange(3)];
[~, modelChangeR] = unique(sort(indexRMSE(:,1)));
freqBestRMSE = [modelChangeR(2)-modelChangeR(1),modelChangeR(3)-modelChangeR(2),length(indexRMSE)+1-modelChangeR(3)];
freqOfBestModelShorter = [freqBestMSE;freqBestRMSE];
freqOfBestModelShorter = table(freqOfBestModelShorter(:,1),freqOfBestModelShorter(:,2),freqOfBestModelShorter(:,3),'VariableNames',{'AR_model','VAR_model','Comparing_model'},'RowNames',{'MSE_Frequency';'RMSE_Frequency'});

clear ii indexMSE indexRMSE modelChange modelChangeR nDates 
clear mse rmse freqBestMSE freqBestRMSE



% plot coeff and via VAR(1)-model estimated coefficients
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


%% KALMAN FILTER:

