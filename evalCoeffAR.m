function [ predCoeff ] = evalCoeffAR( coeff, const, param )
%EVALCOEFFVAR evaluates the coefficients of the volatility surface using a
%VAR(5) model with the parameters const and AR evaluated before

coeff = coeff';
ARsize = length(param);
[sizeCo, widthCo] = size(coeff);
predCoeff = zeros(sizeCo,widthCo);
predCoeff(:,1:ARsize) = coeff(:,1:ARsize);

for ii = ARsize+1:widthCo
    ARvalue = 0;
    for j = 1:ARsize
        ARvalue = ARvalue + param{1,j} * coeff(:,ii-j);
    end
predCoeff(:,ii) = const + ARvalue;
end
predCoeff = predCoeff';
end