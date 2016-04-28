function [ coeff, Rsquared ] = getCoeff( chosenModel, filteredData, evalStart, evalStop)
% In this function the coefficients of a linear model are estimated.
%   depending on the chosenModel, the explanatory variables are chosen.
%   Additionally the ordinary and the adjusted rsquared are estimated
nDates = length(evalStart)-1;
coeff = zeros(length(chosenModel)+1, nDates);
rsquaredOrdinary = zeros(nDates,1);
rsquaredAdjusted = zeros(nDates,1);
for i = 1:nDates    
    thisObs = filteredData(evalStart(i):evalStop(i+1), :);
    
    % get design matrix
    Xmatrix = [thisObs.Moneyness, thisObs.Moneyness.^2, ...
        thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, ...
        thisObs.TimeToMaturity .* thisObs.Moneyness];

    thisModelXmatrix = Xmatrix(:,chosenModel);
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(thisModelXmatrix,thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));
    
    rsquaredOrdinary(i) = mdl.Rsquared.Ordinary;
    rsquaredAdjusted(i) = mdl.Rsquared.Adjusted;
end

coeff = coeff.';
Rsquared = [rsquaredOrdinary, rsquaredAdjusted];
end

