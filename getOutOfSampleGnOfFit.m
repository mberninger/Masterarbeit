function [ gnOfFit ] = getOutOfSampleGnOfFit( k, chosenModel, filteredData, dayChanges )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
%% Permutate the data for every day
addedDays = 0;
randData = zeros(size(filteredData,1),1);
for i = 1:length(dayChanges)-1
    nbOfDays = dayChanges(i+1)-dayChanges(i);
    addedDays = addedDays + nbOfDays;
    permDays = (dayChanges(i)-1 + randperm(nbOfDays));
    randData(dayChanges(i):dayChanges(i+1)-1,1) = permDays.';
end
clear i;

%% now get data table in different, permutated order
dataCallPerm = filteredData(randData, :);

%% now model the data using only 80 percent of the data per day
outOfSample = zeros(1908,1);
inSample = zeros(1908,1);
coeff = zeros(length(chosenModel)+1,1908);
for i = 1:length(dayChanges)-1
    nbOfDays = dayChanges(i+1)-dayChanges(i);
    inSample(i,1) = round(nbOfDays*k);
    outOfSample(i,1) = nbOfDays - inSample(i,1);
    thisObs = dataCallPerm(dayChanges(i):(dayChanges(i)+inSample(i)-1), :);
    Xmatrix = [thisObs.Moneyness, thisObs.Moneyness.^2, ...
        thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, ...
        thisObs.TimeToMaturity .* thisObs.Moneyness];
    model = Xmatrix(:,chosenModel);
    mdl = LinearModel.fit(model, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));
end

clear i;
coeff = coeff.';

%% next I want to check the goodness of fit of the model with the other 20% of the data per day
vola = zeros(size(dataCallPerm,1),3);
vola(:,1) = table2array(dataCallPerm(:,1));
vola(:,3) = table2array(dataCallPerm(:,13));
for i = 1:length(coeff)
    for j = dayChanges(i)+inSample(i):dayChanges(i+1)-1
        M = dataCallPerm.Moneyness(j);
        T = dataCallPerm.TimeToMaturity(j);
        thisObs = [M, M.^2, T, T.^2, M.*T];
        model = thisObs(chosenModel);
        modelEquation = [1, model];
        vola(j,2) = modelEquation*coeff(i,:).';
    end
end

a = vola(:,2) > 0;
vola = vola(a,:);

%% goodness of fit
gnOfFit1 = goodnessOfFit(vola(:,2),vola(:,3),'MSE');
gnOfFit2 = goodnessOfFit(vola(:,2),vola(:,3),'NRMSE');
gnOfFit3 = goodnessOfFit(vola(:,2),vola(:,3),'NMSE');

gnOfFit = [gnOfFit1,gnOfFit2,gnOfFit3];
end

