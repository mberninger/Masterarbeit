function [  ] = plotSurface( k, coeff, chosenModel, filteredData, dayChanges )
%PLOTSURFACE plot estimated vola surface together with observed prices

%%
% set up grid for maturity and moneyness
moneyGrid = 0.8:0.02:1.2;
maturityGrid = 20/225:0.1:510/225;

[M,T] = meshgrid(moneyGrid, maturityGrid);

% Not required anymore: preallocate surface values
% Note: never hardcode values; you had zeros(22,21)
% Z = zeros(size(M));

% vectorize grid values
mVals = M(:);
tVals = T(:);

% get all possible explanatory variables
allExplanVars = [mVals, mVals.^2, tVals, tVals.^2, mVals.*tVals];

% get required explanatory variables only
thisModelExplanVars = allExplanVars(:, chosenModel);
modelEquation = [ones(size(mVals, 1), 1) thisModelExplanVars];

% get implied vola values predicted by model
zVals = modelEquation*coeff(k, :)';

% reshape vector of values to matrix
Z = reshape(zVals', size(M));

% plot surface with transparancy
alphaVal = 0.5;
figure
surface(M, T, Z, 'FaceAlpha', alphaVal)
view(3)

hold on;
obsRange = dayChanges(k):dayChanges(k+1)-1;
scatter3(filteredData.Moneyness(obsRange), filteredData.TimeToMaturity(obsRange), ...
    filteredData.implVol(obsRange), 'filled');
xlabel('Moneyness');
ylabel('Time to Maturity');
zlabel('implied Volatility');
grid on
grid minor
hold off;

end

