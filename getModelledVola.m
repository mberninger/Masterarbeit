function [ vola ] = getModelledVola( filteredData, coeff, chosenModel, dayChanges )
%In order to evaluate the goodness-of-fit the test implied volatility needs
%to be calculated with the used model
%   Detailed explanation goes here

vola = zeros(length(table2array(filteredData)),1);
for i = 1:length(coeff)
    for j = dayChanges(i):dayChanges(i+1)-1
        M = filteredData.Moneyness(j);
        T = filteredData.TimeToMaturity(j);
        thisObs = [M, M.^2, T, T.^2, M.*T];
        model = thisObs(chosenModel);
        modelEquation = [1, model];
        vola(j) = modelEquation*coeff(i,:).';
    end
end

end

