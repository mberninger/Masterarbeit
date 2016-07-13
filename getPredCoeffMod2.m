function [ predCoeffMod2 ] = getPredCoeffMod2( coeff )
%GETPREDCOEFFMOD2 evaluates a vector by shifting each row of the input vector
%one step further
%   The first row of the output vector predCoeffMod2 is equal to the first row
%   of the input vector coeff. All the following rows of predCoeffMod2 are the
%   values from the previous row of coeff, that means: the n'th row of
%   predCoeffMod2 has the values of the n-1'st row of coeff.
nDates = length(coeff);
predCoeffMod2 = zeros(nDates,size(coeff,2));
predCoeffMod2(1,:) = coeff(1,:);
for ii = 2:nDates
predCoeffMod2(ii,:) = coeff(ii-1,:);
end

end

