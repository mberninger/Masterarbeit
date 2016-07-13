function [ predCoeffVAR ] = getPredCoeffVAROut( coeffOut, predLength, lag )
%GETPREDCOEFFVAROUT evaluates the predicted coefficients of the volatility surface using a
%VAR(lag) model with the parameters est.const and est.AR

coeffLength = size(coeffOut,1);

% evaluate the parameters EstSpecOut.a and EstSpecOut.AR of the VAR(lag) 
% model, which models the dynamics of the implied volatility surface:
Spec = vgxset('n',6,'nAR',lag, 'Constant',true);
[EstSpecOut, ~, ~] = vgxvarx(Spec,coeffOut);

% use these parameters and the previous 5 coefficients to
% predict the coefficients for the prediction days:
predCoeffVAR = zeros(predLength,size(coeffOut,2));
estCoeffVAR = coeffOut(coeffLength-lag+1:coeffLength,:);
for ii = 1:predLength
predCoeffVAR(ii,:) = evalCoeffOut(estCoeffVAR,EstSpecOut.a,EstSpecOut.AR);
estCoeffVAR = [estCoeffVAR(2:end,:); predCoeffVAR(ii,:)];
end

end

