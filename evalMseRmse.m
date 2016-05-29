function [mse, rmse] = evalMseRmse( allModels, nRep, kPerc, uniqueDates, filteredData)
% EVALMSERMSE evaluates the mean-squared-error and the root-mean-squared
% error for all days of the sample using out-of-sample testing. This
% evaluation is done nRep-times for each day.
%   mse and rmse are 3-dimensional arrays of size nRep x msize x nDates
%   The third dimension represents the number of days
%   The different rows for one specific day represent the nRep repetitions 
%   of the calculcation 
%   The different columns for one specific day are the five different models

nDates = length(uniqueDates);
msize = size(allModels,1);
mse = zeros(nRep,msize,nDates);
rmse = zeros(nRep,msize,nDates);

for j = 1:nDates;
    thisDate = uniqueDates(j);
    [thisObs,thisObsSize] = getObs(thisDate,filteredData);
    
    for ii = 1:nRep
    [dataInSample, dataOutOfSample] = getSub(thisObsSize,thisObs,kPerc);
    [mse(ii,:,j), rmse(ii,:,j)] = evalDiffModels(allModels, dataInSample, dataOutOfSample, msize );
    end
end

end

