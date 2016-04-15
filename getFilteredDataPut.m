function [ filteredDataPut ] = getFilteredDataPut( data )
% This function filters the data and outputs the filtered data of the call
% options

%% Tabelle aufteilen in Call und Put
dataPut = data(data.IsCall == 0, :);

%% Impliziete Volatilitäten ermitteln/laden
load impliedVolaPut

% implVolPut = blsimpv(dataPut.DAX,dataPut.Strike,dataPut.EONIAmatched,dataPut.TimeToMaturity,dataPut.OptionPrice,[],[],[],{'Put'});

%% Zusammenfassung der Daten und der impliziten Volatilitäten zu einer Tabelle
varName = {'Date'; 'OptionPrice'; 'Bid'; 'Ask'; 'Volume'; 'OpenInterest'; 'Strike'; 'Expiry'; 'DAX'; 'EONIAmatched'; 'TimeToMaturity'; 'IsCall';'implVol'};
dataPut = table( dataPut.Date, dataPut.OptionPrice, dataPut.Bid, dataPut.Ask, dataPut.Volume, dataPut.OpenInterest, dataPut.Strike, dataPut.Expiry, dataPut.DAX, dataPut.EONIAmatched, dataPut.TimeToMaturity, dataPut.IsCall, implVolPut, 'VariableNames', varName);

%% Zunächst werden die Daten gefiltert

%% 1. Schritt: Ober- und Untergrenze von Optionspreisen überprüfen
% Obergrenze Put: P < K (Strikepreis) * exp(-r (Zinssatz)* T (TimeToMaturity))
dataPutObergrenze = dataPut(dataPut.OptionPrice > (dataPut.Strike .* exp(-dataPut.EONIAmatched.*dataPut.TimeToMaturity)), : );
% Untergrenze Put: max(K*e^(-rT)-S_t,0) < P
dataPutUntergrenze = dataPut(dataPut.OptionPrice < max(((dataPut.Strike .* exp(-dataPut.EONIAmatched .* dataPut.TimeToMaturity)) - dataPut.DAX),0), : );

% Entfernen der Wertober- und Wertuntergrenzenfehler aus Datensatz
dataPutFiltered = dataPut(dataPut.OptionPrice > max(((dataPut.Strike .* exp(-dataPut.EONIAmatched .* dataPut.TimeToMaturity)) - dataPut.DAX),0), : );

%% 2. Schritt: negative Zeitwerte ermitteln
dataPutFiltered2 = dataPutFiltered(dataPutFiltered.OptionPrice - max((dataPutFiltered.Strike - dataPutFiltered.DAX), 0) > 0, : );

%% 3. Schritt: 
% nicht weniger als 20 Tage und nicht mehr als 510 Tage bis zur Maturity
dataPutFiltered3 = dataPutFiltered2((dataPutFiltered2.TimeToMaturity .* 255) <= 510 , : );
dataPutFiltered3 = dataPutFiltered3((dataPutFiltered3.TimeToMaturity .* 255) >= 20 , : );

% Moneyness nicht unter 0.8 und nicht über 1.2 
dataPutFiltered4 = dataPutFiltered3((dataPutFiltered3.Strike ./ dataPutFiltered3.DAX) <= 1.2, : );
dataPutFiltered4 = dataPutFiltered4((dataPutFiltered4.Strike ./ dataPutFiltered4.DAX) >= 0.8, : );

% Optionspreis nicht unter 5
dataPutFiltered5 = dataPutFiltered4(dataPutFiltered4.OptionPrice >= 5, : );

%% 4. Schritt: Implied Vola nicht unter 5 und nicht über 50 Prozent
dataPutFiltered6 = dataPutFiltered5(dataPutFiltered5.implVol >= 0.05, : );
dataPutFiltered6 = dataPutFiltered6(dataPutFiltered6.implVol <= 0.5, : );

%% Zuletzt wird die Tabelle um die Moneyness erweitert
varName14 = {'Date'; 'OptionPrice'; 'Bid'; 'Ask'; 'Volume'; 'OpenInterest'; 'Strike'; 'Expiry'; 'DAX'; 'EONIAmatched'; 'TimeToMaturity'; 'IsCall'; 'implVol'; 'Moneyness'};
filteredDataPut = table(dataPutFiltered6.Date, dataPutFiltered6.OptionPrice, dataPutFiltered6.Bid, dataPutFiltered6.Ask, dataPutFiltered6.Volume, dataPutFiltered6.OpenInterest, dataPutFiltered6.Strike, dataPutFiltered6.Expiry, dataPutFiltered6.DAX, dataPutFiltered6.EONIAmatched, dataPutFiltered6.TimeToMaturity, dataPutFiltered6.IsCall, dataPutFiltered6.implVol, dataPutFiltered6.Strike ./ dataPutFiltered6.DAX, 'VariableNames', varName14);


end