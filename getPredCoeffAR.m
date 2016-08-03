function [ predCoeffAR, aic, bic ] = getPredCoeffAR( coeff, lag )
%GETPREDCOEFFAR evaluates the predicted coefficients using an AR(lag)
%model, this is done for every row of the time series coeff,
%Furthermore it evaluates the AIC and BIC of the AR(lag) model
    % the output predCoeffAR is the matrix of the 6 parameter vectors 
    % evaluated by the AR(lag) model and the aic and bic of the model

aic = zeros(1,size(coeff,2));
bic = zeros(1,size(coeff,2));
predCoeffAR = zeros(size(coeff,1),size(coeff,2));

for ii = 1:size(coeff,2);
    m = arima(lag(ii),0,0);
    % estimate the AR(lag) model of the i'th coefficient, est.Constant and
    % est.AR are the parameters of the model:
    [est,~,llh,~] = estimate(m,coeff(:,ii));   
    [aic(:,ii), bic(:,ii)] = aicbic(llh,lag(ii),size(coeff,1)); 
    % evaluate the predicted coefficients using the parameters of the
    % AR(lag) model:
    predCoeffAR(:,ii) = evalCoeff(coeff(:,ii),est.Constant,est.AR');
end

end

