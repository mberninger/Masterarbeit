function [ coeff, Rsquared ] = getCoeff( chosenModel, filteredData, dayChanges)
% In this function the coefficients of a linear model are estimated.
%   depending on the chosenModel, the explanatory variables are chosen.
%   Additionally the ordinary and the adjusted rsquared are estimated
nDates = length(dayChanges)-1;
coeff = zeros(length(chosenModel)+1, nDates);
for i = 1:nDates    
    thisObs = filteredData(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix = [thisObs.Moneyness, thisObs.Moneyness.^2, ...
        thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, ...
        thisObs.TimeToMaturity .* thisObs.Moneyness];

    model = Xmatrix(:,chosenModel);
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(model,thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end

coeff = coeff.';
Rsquared = [mdl.Rsquared.Ordinary, mdl.Rsquared.Adjusted];
end

