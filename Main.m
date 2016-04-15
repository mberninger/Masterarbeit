% THIS IS MY MAIN SCRIPT
clear all;
clc;
close all;

%% Lade Dax-Optionsdaten
load data;

%% Zunächst werden die Daten gefiltered, in Calls und Puts aufgeteilt und die impliziete Volatilität sowie die Moneyness berechnet und hinzugefügt
filteredDataCall = getFilteredDataCall(data);
filteredDataPut = getFilteredDataPut(data);



%% Nun soll die implizite Volatilität modelliert werden
%
%% Ermittle Anzahl der Daten pro Tag
dataPerDay = getDiffDays(filteredDataCall.Date);

%% Koeffizienten für Modell finden; verwendetes Modell: implied volatility = a + b*Moneyness + c*Moneyness^2 + d*TimeToMaturity + e*Moneyness*TimeToMaturity
coeff = zeros(5,1907);
for i = 1:1907
%       Moneyness = filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1);
%       Moneyness_2 = Moneyness.^2;
%       time = filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1);
%       Data_Money = [Moneyness, Moneyness_2, time, time.*Moneyness];
%       iVol = filteredDataCall.implVol(dataPerDay(i):dataPerDay(i+1)-1);
      
    mdl = LinearModel.fit([filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1), filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1).^2, filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1), filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1).*filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1)],filteredDataCall.implVol(dataPerDay(i):dataPerDay(i+1)-1));
    coeff(:,i) = table2array(mdl.Coefficients(:,1));
end
clear i;
coeff = coeff.';

%% Vektor für Anzahl der Tage ermitteln
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

%% ***Hier könnte der Kalman Filter eingesetzt werden???


%% Statt dem Kalman Filter wird hier ein AR Modell verwendet um die implizite Volatilitätsfläche über die Zeit zu betrachten
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

