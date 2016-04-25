function [  ] = plotSurface( k, coeff, chosenModel, filteredData, dayChanges )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[M,T] = meshgrid(0.8:0.02:1.2,20/225:0.1:510/225);
Z = zeros(22,21);
for i = 1:22
    for j = 1:21
        thisObs = [M(i,j), M(i,j).^2, T(i,j), T(i,j).^2, M(i,j).*T(i,j)];
        model = thisObs(chosenModel);
        modelEquation = [1, model];
        Z(i,j) = modelEquation*coeff(k,:).';
    end
end
figure
surface(M,T,Z)
view(3)

hold on;
scatter3(filteredData.Moneyness(dayChanges(k):dayChanges(k+1)-1),filteredData.TimeToMaturity(dayChanges(k):dayChanges(k+1)-1),filteredData.implVol(dayChanges(k):dayChanges(k+1)-1));
xlabel('Moneyness');
ylabel('Time to Maturity');
zlabel('implied Volatility');
grid on
grid minor
hold off;

end

