function [ vola ] = evalVola( chosenData, coeff, chosenModel )
%In order to evaluate the goodness-of-fit the test implied volatility needs
%to be calculated with the used model
%   Detailed explanation goes here
uniqueDates = unique(chosenData.Date);
lengthPrevObs = 0;
vola = zeros(size(chosenData,1),1);
for ii = 1:size(uniqueDates,1)
    
    thisDate = uniqueDates(ii);
    thisObs = getObs(thisDate,chosenData);
    
    mVal = thisObs.Moneyness;
    tVal = thisObs.TimeToMaturity;
    thisModelExplanVars = getExplanVars(mVal, tVal, chosenModel);
    modelEquation = [ones(size(mVal, 1), 1) thisModelExplanVars];
    
    vola(lengthPrevObs + 1:lengthPrevObs + size(thisObs,1),:) = modelEquation*coeff(ii,:).';
    lengthPrevObs = lengthPrevObs + size(thisObs,1);
end

end

