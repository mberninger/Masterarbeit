function [ predCoeff ] = getPredCoeffAROut( coeff, predLength, lag )
%GETPREDCOEFFAROUT evaluates the predicted coefficients of the volatility surface using a
%AR(lag) model with the parameters est.const and est.AR

m = arima(lag,0,0);
[coeffLength, coeffSize] = size(coeff);
predCoeff = zeros(predLength,coeffSize);

for ii = 1:coeffSize
    %estimate the model, est.const and est.AR are the parameter
    est = estimate(m, coeff(:,ii));
    estcoeff = coeff(coeffLength-lag+1:coeffLength,ii);
    for j = 1:predLength        
        predCoeff(j,ii) = evalCoeffOut(estcoeff,est.Constant,est.AR');
        estcoeff = [estcoeff(2:end); predCoeff(j,ii)];
    end
end

end