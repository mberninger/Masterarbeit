function [ filteredDataCall ] = getFilteredDataCall( data )
% This function filters the data and outputs the filtered data of the call
% options

%% Tabelle aufteilen in Call Optionen
dataCall = data(data.IsCall == 1, :);

%% Impliziete Volatilit�ten ermitteln/laden
load impliedVolaCall

% implVolCall = blsimpv(dataCall.DAX,dataCall.Strike,dataCall.EONIAmatched,dataCall.TimeToMaturity,dataCall.OptionPrice,[],[],[],{'Call'});

%% Zusammenfassung der Daten und der impliziten Volatilit�ten zu einer Tabelle

dataCall.implVol = implVolCall;

%% Zun�chst werden die Daten gefiltert

%% 1. Schritt: Ober- und Untergrenze von Optionspreisen �berpr�fen, um Arbitragem�glichkeiten zu vermeiden
% Obergrenze Call: P (Optionspreis) < S_t (Wert des Underlyings)
callUpperBounds = dataCall.DAX;
% Untergrenze Call: max(S_t-K*e^(-rT),0) < P
discountFactor = exp(-dataCall.EONIAmatched .* dataCall.TimeToMaturity);
callLowerBounds = max((dataCall.DAX - (dataCall.Strike .* discountFactor)), 0);

% store messy observations
dataCallObergrenze = dataCall(dataCall.OptionPrice > callUpperBounds, :);
dataCallUntergrenze = dataCall(dataCall.OptionPrice < callLowerBounds, :);

% Entfernen der Wertober- und Wertuntergrenzenfehler aus Datensatz
validArbitrageInds = callLowerBounds < dataCall.OptionPrice & ...
    dataCall.OptionPrice < callUpperBounds ;

%% 2. Schritt: negative Zeitwerte ermitteln und aus dem Datensatz entfernen (je n�her Option am Verfallstermin, desto n�her an Null, aber niemals negativ)

intrinsicVal = max((dataCall.DAX - dataCall.Strike), 0);
timeVal = dataCall.OptionPrice - intrinsicVal;
validTimeValInds = timeVal > 0;

%% 3. Schritt: weitere Filter:
% nicht weniger als 20 Tage und nicht mehr als 510 Tage bis zur Maturity
maturityInDays = dataCall.TimeToMaturity .* 255;
validMaturityInds = 20 <= maturityInDays & maturityInDays <= 510;

% Moneyness nicht unter 0.8 und nicht �ber 1.2 
mnyNess = dataCall.Strike ./ dataCall.DAX;
validMnyNessInds = 0.8 <= mnyNess & mnyNess <= 1.2;

% Optionspreis nicht unter 5
validPriceInds = dataCall.OptionPrice >= 5;

%% 4. Schritt: Implied Vola nicht unter 5 und nicht �ber 50 Prozent
validImplVolaInds = 0.05 <= dataCall.implVol & dataCall.implVol <= 0.5;

%% Zuletzt wird die Tabelle um die Moneyness erweitert
dataCall.Moneyness = mnyNess;

% apply all filters
validInds = validArbitrageInds & validTimeValInds & validMaturityInds & ...
    validMnyNessInds & validPriceInds & validImplVolaInds;

filteredDataCall = dataCall(validInds, :);

end

