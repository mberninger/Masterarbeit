% THIS IS MY MAIN SCRIPT
clear;
clc;
close all;

%% load Dax-optiondata
load data;

%% split data up in calls and puts, evaluate and add implied volatilities, filter the data and evaluate and add the moneyness

% filtering values:
% 1: check upper and lower bounds of option prices:
        % upper bound call: p (option price) < s_t (underlying)
        % upper bound put: p < k (strike price) * exp(-r (interest rate)* t (time to maturity))
        % lower bound call: max(s_t-k*exp(-rt),0) < p
        % lower bound put: max(k*exp(-rt)-s_t,0) < p
% 2: check for negative time values and remove them
% 3: check time to maturity, it should be between 20 and 510 days
% 4: evaluate and check moneyness, it should be between 0.8 and 1.2 
% 5: check option price, it should be bigger than 5
% 6: check implied volatilities, it should be between 5 and 50 percent

filteredDataCall = getFilteredDataCall(data);
filteredDataPut = getFilteredDataPut(data);


%% model implied volatilities for call options
%
%% evaluate the row number where day changes
% get unique dates and row number, where day changes
[uniqueDates, dataPerDay] = unique(filteredDataCall.Date);

% NOTE: old implementation skips observations for last date
% attach value of (last index + 1) to dates
dayChanges = [dataPerDay; size(filteredDataCall, 1)+1];

%% find coefficients for model; choose model coefficients: 
% choose from possible explanatory variables: 1 = moneyness, 2 =
% moneyness^2, 3 = timeToMaturity, 4 = timeToMaturity^2, 5 =
% moneyness*timeToMaturity
model = [1, 3, 5];
[coeff, Rsquared] = getCoeff(model, filteredDataCall, dayChanges);

%% plot coefficients of model
plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
legend('a','b','c','d','e')
title('Model coefficients')
% TODO: find suitable names for coefficients

%% Goodness-of-fit:
% other goodness-of-fit test:   
%       mean square error: 'MSE' (0 = perfect fit)
%       normalized root mean square error: 'NRMSE' (1 = perfect fit)
%       normalized mean square error: 'NMSE' (1 = perfect fit)
vola = getModelledVola(filteredDataCall, coeff, model, dayChanges);

gnOfFit = goodnessOfFit(vola,filteredDataCall.implVol,'MSE');
% gnOfFit = goodnessOfFit(vola,filteredDataCall.implVol,'NRMSE');
% gnOfFit = goodnessOfFit(vola,filteredDataCall.implVol,'NMSE');

%% plot volatility surface with estimated coefficients
% choose the day in the first input variable
% the boundarys for the moneyness and the time to maturity are the same as
% chosen for filtering the data, so
    % 0.8 < moneyness < 1.2
    % 20 < timeToMaturity .*225 < 510
plotSurface(13,coeff,model,filteredDataCall,dayChanges);

%% get the goodness of fit out-of-sample for chosen model
% choose percentage for out-of-sample data
model = [1,2,3,4,5];
gnOfFitOutOfSample3 = getOutOfSampleGnOfFit(0.8,model,filteredDataCall,dayChanges);

%% TODO: next steps
% - goodness-of-fit: how good does estimated smooth surface describe real
% implied volatilities?
            % still ToDo: out-of-sample goodness-of-fit

% - are all explanatory variables required, or could a more sparse model
% (e.g. moneyness and maturity only) provide a better solution?
% NOTE: adding explanatory variables does always increase IN-SAMPLE fit.
% But more sparse models can be better OUT-OF-SAMPLE
% - conduct out-of-sample forecast for real future option prices with
% given estimated models

% - create function to plot smooth surface for given coefficients (find
% meaningful ranges for x and y values (moneyness, maturity) 
            % => done
% - plot smooth surface vs implied volatility observations
            % => done
% - make plot variables with regards to parameters: estimated volatility
% surfaces of different models should be comparable

% - how sensitive are all results with regards to chosen data filtering?
% - some descriptive statistics: 
%   - observations per day
%   - observed maturities per day
%   - number of filtered observations
%   - ...

% - visualize dependency between estimated coefficients: 
%   - are they independent?
%   - is it reasonable to model them in 5 separate univariate AR models, or
%     do we need a 5-dimensional joint model

%% dependency of estimated coefficients
depOfCoeff = corr(coeff);


%% fit VAR model
Spec = vgxset('n',5,'nAR',1, 'Constant',true);
EstSpec = vgxvarx(Spec,coeff);
% simulate coeff for 100 obs
H = vgxsim(EstSpec,100);

%% plot simulated coefficients of model
figure;
plot(1:100, H)
grid on
grid minor
datetick 'x'
legend('a','b','c','d','e')
title('Model coefficients')

%% plot volatility surface of simulated model for day k
% choose k 
k = 1;
[X,Y] = meshgrid(0.8:0.02:1.2,20/225:0.1:510/225);
Z = H(k,1) + H(k,2) .* X + H(k,3) .* X.^2 + H(k,4) .* Y + H(k,5) .* X .* Y;
figure
surface(X,Y,Z)
view(3)




%% Vektor f�r Anzahl der Tage ermitteln
% tag = ones(1907,1); 
% for i = 2:1907
%     tag(i) = tag(i-1)+1;
% end
% clear i;
% 
% 
% %% Simulate AR Modell for different Coefficients
% %% Get AR coefficients for different linear Model coefficients
% model = arima(1,0,0);
% % 1. Koeffizient:
% ARCoeff1 = estimate(model, coeff(:,1));
% % 2. Koeffizient:
% ARCoeff2 = estimate(model, coeff(:,2));
% % 3. Koeffizient:
% ARCoeff3 = estimate(model, coeff(:,3));
% % 4. Koeffizient:
% ARCoeff4 = estimate(model, coeff(:,4));
% % 5. Koeffizient:
% ARCoeff5 = estimate(model, coeff(:,5));
% 
% %% ***Hier k�nnte der Kalman Filter eingesetzt werden???
% 
% 
% %% Statt dem Kalman Filter wird hier ein AR Modell verwendet um die implizite Volatilit�tsfl�che �ber die Zeit zu betrachten
% rng default; % for reproducability
% % 1.Koeffizient
% sim1 = simulate(ARCoeff1,1900,'NumPaths',1000,'Y0',coeff(:,1));
% % 2.Koeffizient
% sim2 = simulate(ARCoeff2,1900,'NumPaths',1000,'Y0',coeff(:,2));
% % 3.Koeffizient
% sim3 = simulate(ARCoeff3,1900,'NumPaths',1000,'Y0',coeff(:,3));
% % 4.Koeffizient
% sim4 = simulate(ARCoeff4,1900,'NumPaths',1000,'Y0',coeff(:,4));
% % 5.Koeffizient
% sim5 = simulate(ARCoeff5,1900,'NumPaths',1000,'Y0',coeff(:,5));
% 
