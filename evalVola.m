function [ vola ] = evalVola( chosenData, coeff, chosenModel, evalStart, evalStop )
%In order to evaluate the goodness-of-fit the test implied volatility needs
%to be calculated with the used model
%   Detailed explanation goes here

vola = zeros(size(chosenData,1),1);
for i = 1:length(coeff)
    mVal = chosenData.Moneyness(evalStart(i):evalStop(i+1));
    tVal = chosenData.TimeToMaturity(evalStart(i):evalStop(i+1));
    allExplanVars = [mVal, mVal.^2, tVal, tVal.^2, mVal.*tVal];
    thisModelExplanVars = allExplanVars(:, chosenModel);
    modelEquation = [ones(size(mVal, 1), 1) thisModelExplanVars];
    vola(evalStart(i):evalStop(i+1),:) = modelEquation*coeff(i,:).';
    
end

end

