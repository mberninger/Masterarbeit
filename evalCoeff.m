function [ predCoeff ] = evalCoeff( coeff, const, AR )
%EVALCOEFF evaluates the coefficients of the volatility surface using an
%AR(length(AR)) or VAR(length(AR)) model with the parameters const and AR 
%evaluated before

coeff = coeff';
ARsize = length(AR);
[sizeCo, widthCo] = size(coeff);
predCoeff = zeros(sizeCo,widthCo);
predCoeff(:,1:ARsize) = coeff(:,1:ARsize);

for ii = ARsize+1:widthCo
    ARvalue = 0;
    for j = 1:ARsize
        ARvalue = ARvalue + AR{j,1} * coeff(:,ii-j);
    end
    predCoeff(:,ii) = const + ARvalue;
end
predCoeff = predCoeff';

end


