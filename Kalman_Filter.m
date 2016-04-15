%% Hier möchte ich den Kalman-Filter anwenden, um die Volatilitätsflächen zu bestimmen.

%% Find vAll, the difference between estimated vola and implied vola for every datapoint:
laenge = 0;
s = zeros(1907,1);
vola = zeros(432810,1);
for i = 1:1906
    s(i) = dataPerDay(i+1)-dataPerDay(i);
    for j = 1+laenge:s+laenge
        M = filteredDataCall.Moneyness(j);
        T = filteredDataCall.TimeToMaturity(j);
        vola(j) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2 + coeff(i,4).*T + coeff(i,5).*T.*M;
    end
    laenge = laenge + s(i);
end

vAll = filteredDataCall.implVol(1:432810) - vola;

%% Find v, the difference between implied volatility and modelled vola, for every day
iVol = zeros(1907,1);
volaModel = zeros(1907,1);
for i = 1:1907
    iVol(i,1) = sum(filteredDataCall.implVol(dataPerDay(i):dataPerDay(i+1)-1))./(dataPerDay(i+1)-dataPerDay(i));
    M = sum(filteredDataCall.Moneyness(dataPerDay(i):dataPerDay(i+1)-1))./(dataPerDay(i+1)-dataPerDay(i));
    T = sum(filteredDataCall.TimeToMaturity(dataPerDay(i):dataPerDay(i+1)-1))./(dataPerDay(i+1)-dataPerDay(i));
    volaModel(i,1) = coeff(i,1) + coeff(i,2).*M + coeff(i,3).*M.^2 + coeff(i,4).*T + coeff(i,5).*T.*M;
end
clear i;

v = iVol - volaModel;


%% Find w, the difference between the actual coefficient and the modelled coefficient
modelledCoeff = zeros(1907,5);
modelledCoeff(1,1) = coeff(1,1);
w = zeros(1907,5);
    modelledCoeff(1,1) = coeff(1,1);
    for i = 2:1907
        modelledCoeff(i,1) = ARCoeff1.Constant + cell2mat(ARCoeff1.AR) .* modelledCoeff(i-1,1);
    end
    
    w(:,1) = coeff(:,1) - modelledCoeff(:,1);
%
modelledCoeff(1,1) = coeff(1,2);
    for i = 2:1907
        modelledCoeff(i,1) = ARCoeff2.Constant + cell2mat(ARCoeff2.AR) .* modelledCoeff(i-1,1);
    end
    
    w(:,2) = coeff(:,2) - modelledCoeff(:,1);
%
modelledCoeff(1,1) = coeff(1,3);
    for i = 2:1907
        modelledCoeff(i,1) = ARCoeff3.Constant + cell2mat(ARCoeff3.AR) .* modelledCoeff(i-1,1);
    end
    w(:,3) = coeff(:,3) - modelledCoeff(:,1);
%
modelledCoeff(1,1) = coeff(1,4);
    for i = 2:1907
        modelledCoeff(i,1) = ARCoeff4.Constant + cell2mat(ARCoeff4.AR) .* modelledCoeff(i-1,1);
    end
    w(:,4) = coeff(:,4) - modelledCoeff(:,1);
%        
modelledCoeff(1,1) = coeff(1,5);
    for i = 2:1907
        modelledCoeff(i,1) = ARCoeff5.Constant + cell2mat(ARCoeff5.AR) .* modelledCoeff(i-1,1);
    end
    w(:,5) = coeff(:,5) - modelledCoeff(:,1);

clear i;


% %% Ermitteln der Kovarianzen: cov(w) = R, cov(coeff) = Q;
% R = cov(w);
% Q = cov(coeff);

%% Ermitteln der Kovarianzen: cov(w) = R, cov(coeff) = Q;
R = cov(v);
Q = cov(w);
u = eye(5);
% B = Koeffizient 1 den wir finden wollen: A
% F = Koeffizient 2 den wir finden wollen: B
X = coeff;
P = cov(coeff);
%% 

