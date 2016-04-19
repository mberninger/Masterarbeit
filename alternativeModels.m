%% In this script I use different models, to search for a better solution

%% Alternative model 1: model_1 = a + b*moneyness + c*timeToMaturity

nDates = size(uniqueDates, 1);
coeff = zeros(3, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.TimeToMaturity];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';

%% alternative model 2: model_2 = a + b*moneyness + c*moneyness^2

nDates = size(uniqueDates, 1);
coeff = zeros(3, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.Moneyness.^2];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';


%% alternative model 3: model_3 = a + b*moneyness + c*moneyness^2 + d*timeToMaturity + e*timeToMaturity^2 + f*timeToMaturity*Moneyness

nDates = size(uniqueDates, 1);
coeff = zeros(6, nDates);
for i = 1:nDates

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(i):dayChanges(i+1)-1, :);
    
    % get design matrix
    Xmatrix_1 = [thisObs.Moneyness, thisObs.Moneyness.^2, thisObs.TimeToMaturity, thisObs.TimeToMaturity.^2, thisObs.TimeToMaturity.*thisObs.Moneyness];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix_1, thisObs.implVol);
    coeff(:,i) = table2array(mdl.Coefficients(:,1));

end
clear i;
coeff = coeff.';


%% plot coefficients of model
figure;
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('a','b','c','d','e')
title('Model coefficients')
% TODO: find suitable names for coefficients

%% Goodness-of-fit:
% for examaple: Rsquared-test: (1 = perfect fit)
gnOfFit1 = mdl.Rsquared.Ordinary;
gnOfFit2 = mdl.Rsquared.Adjusted;

% other goodness-of-fit test:   
%       mean square error: 'MSE' (0 = perfect fit)
%       normalized root mean square error: 'NRMSE' (1 = perfect fit)
%       normalized mean square error: 'NMSE' (1 = perfect fit)

% if model_1 is chosen, otherwise adjust the model function in the function
% getAltModelledVola
vola = getAltModelledVola(filteredDataCall, coeff, dayChanges);

% load vola;
gnOfFit3 = goodnessOfFit(vola,filteredDataCall.implVol,'MSE');
gnOfFit4 = goodnessOfFit(vola,filteredDataCall.implVol,'NRMSE');
gnOfFit5 = goodnessOfFit(vola,filteredDataCall.implVol,'NMSE');

%% plot volatility surface with estimated coefficients
% choose in k the day
% the boundarys for the moneyness and the time to maturity are the same as
% chosen for filtering the data, so
    % 0.8 < moneyness < 1.2
    % 20 < timeToMaturity .*225 < 510
k = 123;
[X,Y] = meshgrid(0.8:0.02:1.2,20/225:0.1:510/225);
% if model_1 is chosen:
    Z = coeff(k,1) + coeff(k,2) .* X + coeff(k,3) .* Y;
% if model_2 is chosen:
%     Z = coeff(k,1) + coeff(k,2) .* X + coeff(k,3) .* X.^2;
% if model_3 is chosen:
%     Z = coeff(k,1) + coeff(k,2) .* X + coeff(k,3) .* X.^2 + coeff(k,4) .* Y + coeff(k,5) .* Y.^2 + coeff(k,6) .* X .* Y;
figure
surface(X,Y,Z)
view(3)

hold on;
scatter3(filteredDataCall.Moneyness(dataPerDay(k):dataPerDay(k+1)-1),filteredDataCall.TimeToMaturity(dataPerDay(k):dataPerDay(k+1)-1),filteredDataCall.implVol(dataPerDay(k):dataPerDay(k+1)-1));
xlabel('Moneyness');
ylabel('Time to Maturity');
zlabel('implied Volatility');
hold off;
%% dependency of estimated coefficients
depOfCoeff = corr(coeff);


%% fit VAR model
% if model_1 or model_2 are chosen
    Spec = vgxset('n',3,'nAR',1, 'Constant',true);
% if model_3 is chosen:
%     Spec = vgxset('n',6,'nAR',1, 'Constant',true);
EstSpec = vgxvarx(Spec,coeff);
% simulate coeff for 100 obs
H = vgxsim(EstSpec,100);

%% plot simulated coefficients of model
plot(1:100, H)
grid on
grid minor
datetick 'x'
legend('a','b','c','d','e','f')
title('Model coefficients')

%% plot volatility surface of simulated model for day k
% choose k 
k = 1;
[X,Y] = meshgrid(0.8:0.02:1.2,20/225:0.1:510/225);
% if model_1 is chosen:
    Z = H(k,1) + H(k,2) .* X + H(k,3) .* Y;
% if model_2 is chosen:
%     Z = H(k,1) + H(k,2) .* X + H(k,3) .* X.^2;
% if model_3 is chosen:
%     Z = H(k,1) + H(k,2) .* X + H(k,3) .* X.^2 + H(k,4).*Y + H(k,5).*Y.^2 + H(k,6).*X.*Y;
figure
surface(X,Y,Z)
view(3)
