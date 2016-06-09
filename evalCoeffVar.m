function [ predCoeff ] = evalCoeffVar( coeff, const, AR )
%EVALCOEFFVAR evaluates the coefficients of the volatility surface using a
%VAR(5) model with the parameters const and AR evaluated before

coeff = coeff';
ARsize = length(AR);
size = length(coeff);
predCoeff = zeros(6,size);
predCoeff(:,1:ARsize) = coeff(:,1:ARsize);

for ii = ARsize+1:size
    ARvalue = 0;
    for j = 1:ARsize
        ARvalue = ARvalue + AR{j,1} * coeff(:,ii-j);
    end
    predCoeff(:,ii) = const + ARvalue;
end
predCoeff = predCoeff';

end


