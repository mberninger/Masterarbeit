function [ param ] = evalCoeffAR( coeff, coeffLength, coeffSize, lag )
%EVALCOEFFVAR evaluates the coefficients of the volatility surface using a
%VAR(5) model with the parameters const and AR evaluated before

m = arima(lag,0,0);
param = zeros(6,coeffSize);

for ii = 1:coeffSize
    est = estimate(m, coeff(:,ii));
    param(:,ii) = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,ii),est.Constant,est.AR');
end

    
% %old:    
% m = arima(lag,0,0);
% est1 = estimate(m,coeff(:,1));
% est2 = estimate(m,coeff(:,2));
% est3 = estimate(m,coeff(:,3));
% est4 = estimate(m,coeff(:,4));
% est5 = estimate(m,coeff(:,5));
% est6 = estimate(m,coeff(:,6));
% 
% %[a1,b1]= aicbic(logL1,5,size(coeff,1));
% %[a2,b2]= aicbic(logL2,5,size(coeff,2));
% %[a3,b3]= aicbic(logL3,5,size(coeff,3));
% %[a4,b4]= aicbic(logL4,5,size(coeff,4));
% %[a5,b5]= aicbic(logL5,5,size(coeff,5));
% %[a6,b6]= aicbic(logL6,5,size(coeff,6));
% 
% param1 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,1),est1.Constant,est1.AR');
% param2 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,2),est2.Constant,est2.AR');
% param3 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,3),est3.Constant,est3.AR');
% param4 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,4),est4.Constant,est4.AR');
% param5 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,5),est5.Constant,est5.AR');
% param6 = evalCoeffVar(coeff(coeffLength-coeffSize+1:coeffLength,6),est6.Constant,est6.AR');
% param2 = [param1,param2,param3,param4,param5,param6];

% % % coeff = coeff';
% % % ARsize = length(param);
% % % [sizeCo, widthCo] = size(coeff);
% % % predCoeff = zeros(sizeCo,widthCo);
% % % predCoeff(:,1:ARsize) = coeff(:,1:ARsize);
% % % 
% % % for ii = ARsize+1:widthCo
% % %     ARvalue = 0;
% % %     for j = 1:ARsize
% % %         ARvalue = ARvalue + param(1,j) * coeff(:,ii-j);
% % %     end
% % % predCoeff(:,ii) = const + ARvalue;
% % % end
% % % predCoeff = predCoeff';
end