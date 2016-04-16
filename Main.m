% THIS IS MY MAIN SCRIPT
clear all;
clc;
close all;

%% Lade Dax-Optionsdaten
load data;

%% Zun�chst werden die Daten gefiltered, in Calls und Puts aufgeteilt und die impliziete Volatilit�t sowie die Moneyness berechnet und hinzugef�gt

% NOTE: specify filtering values outside of function as structure

filteredDataCall = getFilteredDataCall(data);
filteredDataPut = getFilteredDataPut(data);



%% Nun soll die implizite Volatilit�t modelliert werden
%
%% Ermittle Anzahl der Daten pro Tag

% NOTE: function only works if dates are really sorted
filteredDataCall = sortrows(filteredDataCall, 'Date');

dataPerDay2 = getDiffDays(filteredDataCall.Date);

%% find date changes

dateChange = filteredDataCall.Date(1:end-1) ~= filteredDataCall.Date(2:end);
dateChange = [true; dateChange];
dataPerDay = find(dateChange);

assert(all(dataPerDay == dataPerDay2))

% get unique dates
uniqueDates = unique(filteredDataCall.Date);

% NOTE: old implementation skips observations for last date
% attach value of (last index + 1) to dates
dayChanges = [dataPerDay; size(filteredDataCall, 1)+1];

%% Koeffizienten f�r Modell finden; verwendetes Modell: implied volatility = a + b*Moneyness + c*Moneyness^2 + d*TimeToMaturity + e*Moneyness*TimeToMaturity
nDates = size(uniqueDates, 1);
coeff = zeros(5, nDates);
for ii = 1:nDates
%       Moneyness = filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1);
%       Moneyness_2 = Moneyness.^2;
%       time = filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1);
%       Data_Money = [Moneyness, Moneyness_2, time, time.*Moneyness];
%       iVol = filteredDataCall.implVol(dataPerDay(i):dataPerDay(i+1)-1);

    % get all observations for current day
    thisObs = filteredDataCall(dayChanges(ii):dayChanges(ii+1)-1, :);
    
    % get design matrix
    Xmatrix = [thisObs.Moneyness, thisObs.Moneyness.^2, ...
        thisObs.TimeToMaturity, ...
        thisObs.TimeToMaturity .* thisObs.Moneyness];
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(Xmatrix, thisObs.implVol);
    coeff(:,ii) = table2array(mdl.Coefficients(:,1));

end
clear ii;
coeff = coeff.';

%%

plot(uniqueDates, coeff)
grid on
grid minor
datetick 'x'
% TODO: attach labels (legend?) to coefficients

%% TODO: next steps
% - goodness-of-fit: how good does estimated smooth surface describe real
% implied volatilities?
% - are all explanatory variables required, or could a more sparse model
% (e.g. moneyness and maturity only) provide a better solution?
% NOTE: adding explanatory variables does always increase IN-SAMPLE fit.
% But more sparse models can be better OUT-OF-SAMPLE
% - conduct out-of-sample forecast for real future option prices with
% given estimated models
% - create function to plot smooth surface for given coefficients (find
% meaningful ranges for x and y values (moneyness, maturity)
% - plot smooth surface vs implied volatility observations
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

%% Vektor f�r Anzahl der Tage ermitteln
tag = ones(1907,1); 
for i = 2:1907
    tag(i) = tag(i-1)+1;
end
clear i;


%% Simulate AR Modell for different Coefficients
%% Get AR coefficients for different linear Model coefficients
model = arima(1,0,0);
% 1. Koeffizient:
ARCoeff1 = estimate(model, coeff(:,1));
% 2. Koeffizient:
ARCoeff2 = estimate(model, coeff(:,2));
% 3. Koeffizient:
ARCoeff3 = estimate(model, coeff(:,3));
% 4. Koeffizient:
ARCoeff4 = estimate(model, coeff(:,4));
% 5. Koeffizient:
ARCoeff5 = estimate(model, coeff(:,5));

%% ***Hier k�nnte der Kalman Filter eingesetzt werden???


%% Statt dem Kalman Filter wird hier ein AR Modell verwendet um die implizite Volatilit�tsfl�che �ber die Zeit zu betrachten
rng default; % for reproducability
% 1.Koeffizient
sim1 = simulate(ARCoeff1,1900,'NumPaths',1000,'Y0',coeff(:,1));
% 2.Koeffizient
sim2 = simulate(ARCoeff2,1900,'NumPaths',1000,'Y0',coeff(:,2));
% 3.Koeffizient
sim3 = simulate(ARCoeff3,1900,'NumPaths',1000,'Y0',coeff(:,3));
% 4.Koeffizient
sim4 = simulate(ARCoeff4,1900,'NumPaths',1000,'Y0',coeff(:,4));
% 5.Koeffizient
sim5 = simulate(ARCoeff5,1900,'NumPaths',1000,'Y0',coeff(:,5));

