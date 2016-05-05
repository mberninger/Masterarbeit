function [mse, rmse] = evalMseRmse( allModels, nRep, kPerc, uniqueDates, filteredData)
% EVALGNOFFIT evaluates the mean-squared-error and the root-mean-squared
% error for all possible models using out-of-sample testing

mse = zeros(length(uniqueDates),size(allModels,1));
rmse = zeros(length(uniqueDates),size(allModels,1));

for j = 1:length(uniqueDates);
    thisDate = uniqueDates(j);
    [thisObs,thisObsSize] = getObs(thisDate,filteredData);
    [dataInSample, dataOutOfSample] = getSub(thisObsSize, thisObs, nRep, kPerc);
    
    [mse(j,:), rmse(j,:)] = evalDiffModels(allModels,dataInSample,dataOutOfSample);
end

end

