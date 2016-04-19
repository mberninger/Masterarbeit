function [ vola ] = getModelledVola( filteredData, coeff, dayChanges )
%In order to evaluate the goodness-of-fit the test implied volatility needs
%to be calculated with the used model
%   Detailed explanation goes here

vola = zeros(length(table2array(filteredData)),1);
for i = 1:length(coeff)
    for j = dayChanges(i):dayChanges(i+1)-1
        M = filteredData.Moneyness(j);
        T = filteredData.TimeToMaturity(j);
        vola(j) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2 + coeff(i,4).*T + coeff(i,5).*T.*M;
    end
end

end

