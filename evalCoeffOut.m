function [ predCoeff ] = evalCoeffOut( coeff, const, AR )
%EVALCOEFFVAR evaluates the coefficients of the volatility surface using a
%VAR(length(AR)) model with the parameters const and AR evaluated before

coeff = coeff';
ARsize = length(AR);
ARvalue = 0;

for j = 1:ARsize
    ARvalue = ARvalue + AR{j,1} * coeff(:,ARsize+1-j);    
end
predCoeff = const + ARvalue;
    
predCoeff = predCoeff';

end
