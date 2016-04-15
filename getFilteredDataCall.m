function [ filteredDataCall ] = getFilteredDataCall( data )
% This function filters the data and outputs the filtered data of the call
% options

%% Tabelle aufteilen in Call Optionen
dataCall = data(data.IsCall == 1, :);

%% Impliziete Volatilitäten ermitteln/laden
load impliedVolaCall

% implVolCall = blsimpv(dataCall.DAX,dataCall.Strike,dataCall.EONIAmatched,dataCall.TimeToMaturity,dataCall.OptionPrice,[],[],[],{'Call'});

%% Zusammenfassung der Daten und der impliziten Volatilitäten zu einer Tabelle
varName = {'Date'; 'OptionPrice'; 'Bid'; 'Ask'; 'Volume'; 'OpenInterest'; 'Strike'; 'Expiry'; 'DAX'; 'EONIAmatched'; 'TimeToMaturity'; 'IsCall';'implVol'};
dataCall = table( dataCall.Date, dataCall.OptionPrice, dataCall.Bid, dataCall.Ask, dataCall.Volume, dataCall.OpenInterest, dataCall.Strike, dataCall.Expiry, dataCall.DAX, dataCall.EONIAmatched, dataCall.TimeToMaturity, dataCall.IsCall, implVolCall, 'VariableNames', varName);

%% Zunächst werden die Daten gefiltert

%% 1. Schritt: Ober- und Untergrenze von Optionspreisen überprüfen, um Arbitragemöglichkeiten zu vermeiden
% Obergrenze Call: P (Optionspreis) < S_t (Wert des Underlyings)
dataCallObergrenze = dataCall(dataCall.OptionPrice > dataCall.DAX, : );
% Untergrenze Call: max(S_t-K*e^(-rT),0) < P
dataCallUntergrenze = dataCall(dataCall.OptionPrice < max((dataCall.DAX - (dataCall.Strike .* exp(-dataCall.EONIAmatched .* dataCall.TimeToMaturity))),0), : );

% Entfernen der Wertober- und Wertuntergrenzenfehler aus Datensatz
dataCallFiltered = dataCall(dataCall.OptionPrice > max((dataCall.DAX - (dataCall.Strike .* exp(-dataCall.EONIAmatched .* dataCall.TimeToMaturity))),0), : );

%% 2. Schritt: negative Zeitwerte ermitteln und aus dem Datensatz entfernen (je näher Option am Verfallstermin, desto näher an Null, aber niemals negativ)
dataCallFiltered2 = dataCallFiltered(dataCallFiltered.OptionPrice - max((dataCallFiltered.DAX - dataCallFiltered.Strike), 0) > 0, : );

%% 3. Schritt: weitere Filter:
% nicht weniger als 20 Tage und nicht mehr als 510 Tage bis zur Maturity
dataCallFiltered3 = dataCallFiltered2((dataCallFiltered2.TimeToMaturity .* 255) <= 510 , : );
dataCallFiltered3 = dataCallFiltered3((dataCallFiltered3.TimeToMaturity .* 255) >= 20 , : );

% Moneyness nicht unter 0.8 und nicht über 1.2 
dataCallFiltered4 = dataCallFiltered3((dataCallFiltered3.Strike ./ dataCallFiltered3.DAX) <= 1.2, : );
dataCallFiltered4 = dataCallFiltered4((dataCallFiltered4.Strike ./ dataCallFiltered4.DAX) >= 0.8, : );

% Optionspreis nicht unter 5
dataCallFiltered5 = dataCallFiltered4(dataCallFiltered4.OptionPrice >= 5, : );

%% 4. Schritt: Implied Vola nicht unter 5 und nicht über 50 Prozent
dataCallFiltered6 = dataCallFiltered5(dataCallFiltered5.implVol >= 0.05, : );
dataCallFiltered6 = dataCallFiltered6(dataCallFiltered6.implVol <= 0.5, : );

%% Zuletzt wird die Tabelle um die Moneyness erweitert
varName14 = {'Date'; 'OptionPrice'; 'Bid'; 'Ask'; 'Volume'; 'OpenInterest'; 'Strike'; 'Expiry'; 'DAX'; 'EONIAmatched'; 'TimeToMaturity'; 'IsCall'; 'implVol'; 'Moneyness'};
filteredDataCall = table(dataCallFiltered6.Date, dataCallFiltered6.OptionPrice, dataCallFiltered6.Bid, dataCallFiltered6.Ask, dataCallFiltered6.Volume, dataCallFiltered6.OpenInterest, dataCallFiltered6.Strike, dataCallFiltered6.Expiry, dataCallFiltered6.DAX, dataCallFiltered6.EONIAmatched, dataCallFiltered6.TimeToMaturity, dataCallFiltered6.IsCall, dataCallFiltered6.implVol, dataCallFiltered6.Strike ./ dataCallFiltered6.DAX, 'VariableNames', varName14);

end

