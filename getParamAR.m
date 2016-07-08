function [ param, aic, bic ] = getParamAR( coeff, lag )
%GETPARAMAR evaluates the parameter for an AR(5) model, this is done for
%the time series of every row of coeff
    % the output param is the matrix of the 6 parameter vectors evaluated
    % by the AR(5) model.

m = arima(lag,0,0);
[est1,~,llh1,~] = estimate(m,coeff(:,1));
[est2,~,llh2,~] = estimate(m,coeff(:,2));
[est3,~,llh3,~] = estimate(m,coeff(:,3));
[est4,~,llh4,~] = estimate(m,coeff(:,4));
[est5,~,llh5,~] = estimate(m,coeff(:,5));
[est6,~,llh6,~] = estimate(m,coeff(:,6));

[a1,b1]= aicbic(llh1,5,size(coeff,1));
[a2,b2]= aicbic(llh2,5,size(coeff,2));
[a3,b3]= aicbic(llh3,5,size(coeff,3));
[a4,b4]= aicbic(llh4,5,size(coeff,4));
[a5,b5]= aicbic(llh5,5,size(coeff,5));
[a6,b6]= aicbic(llh6,5,size(coeff,6));
aic = [a1,a2,a3,a4,a5,a6];
bic = [b1,b2,b3,b4,b5,b6];

param1 = evalCoeffVar(coeff(:,1),est1.Constant,est1.AR');
param2 = evalCoeffVar(coeff(:,2),est2.Constant,est2.AR');
param3 = evalCoeffVar(coeff(:,3),est3.Constant,est3.AR');
param4 = evalCoeffVar(coeff(:,4),est4.Constant,est4.AR');
param5 = evalCoeffVar(coeff(:,5),est5.Constant,est5.AR');
param6 = evalCoeffVar(coeff(:,6),est6.Constant,est6.AR');
param = [param1,param2,param3,param4,param5,param6];

end

