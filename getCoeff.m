function [ coeff, Rsquared ] = getCoeff( chosenModel, filteredData )
% In this function the coefficients of a linear model are estimated.
%   depending on the chosenModel, the explanatory variables are chosen.
%   Additionally the model criterion AIC, AICc, BIC, CAIC are 
uniqueDates = unique(filteredData.Date);
nDates = length(uniqueDates);
coeff = zeros(length(chosenModel)+1, nDates);
rsquaredOrdinary = zeros(nDates,1);
rsquaredAdjusted = zeros(nDates,1);
for ii = 1:nDates    
    
    thisDate = uniqueDates(ii);
    thisObs = getObs(thisDate,filteredData);
    
    % get design matrix for chosen model
    thisModelXmatrix = getExplanVars(thisObs.Moneyness, thisObs.TimeToMaturity, chosenModel);
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(thisModelXmatrix,thisObs.implVol);
    coeff(:,ii) = table2array(mdl.Coefficients(:,1));
    rsquaredOrdinary(ii) = mdl.Rsquared.Ordinary;
    rsquaredAdjusted(ii) = mdl.Rsquared.Adjusted;
end

coeff = coeff.';
Rsquared = [rsquaredOrdinary, rsquaredAdjusted];
end

