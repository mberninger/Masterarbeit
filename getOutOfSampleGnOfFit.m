function [ gnOfFit ] = getOutOfSampleGnOfFit( k, chosenModel, filteredData, dayChanges )
%GETOUTOFSAMPLEGNOFFIT evaluates the goodness-of-fit for an out-of-sample
%subsample
%   k is the percentage of the in-sample subsample
%% evaluate dataCallPerm, the data, which is permutated for every day
%   furthermore, the first and last datapoint for every day are stored in
%   the variables evalStart and evalStop, they are needed for further
%   estimations
[dataCallPerm, evalStart, evalStop] = getRandSubsample(k, filteredData, dayChanges);

%% model the data using only k*100 percent of the data per day
coeff = getCoeff(chosenModel, dataCallPerm, evalStart, evalStop);


%% check the goodness of fit of the model with the other (1-k)*100 percent of the data per day
vola = zeros(size(dataCallPerm,1),3);
vola(:,1) = table2array(dataCallPerm(:,1));
vola(:,3) = table2array(dataCallPerm(:,13));
vola(:,2) = evalVola(dataCallPerm, coeff, chosenModel, evalStop, dayChanges-1);
%   select only the out-of-sample data points
a = vola(:,2) > 0;
vola = vola(a,:);

%% goodness of fit for out-of-sample
gnOfFit1 = goodnessOfFit(vola(:,2),vola(:,3),'MSE');
gnOfFit2 = goodnessOfFit(vola(:,2),vola(:,3),'NRMSE');
gnOfFit3 = goodnessOfFit(vola(:,2),vola(:,3),'NMSE');

gnOfFit = [gnOfFit1,gnOfFit2,gnOfFit3];
end

