function [ predCoeffVAR, bic ] = getPredCoeffVAR( coeff, lag )
%GETPREDCOEFFVAR evaluates the predicted coefficients using an VAR(lag)
%model
%Furthermore it evaluates the BIC of the VAR(lag) model
    % the output predCoeffVAR is the matrix of the 6 parameter vectors 
    % evaluated by the VAR(lag) model and the bic of the model

% estimate the VAR(lag) model in order to get  the parameter EstSpec.a and 
% EstSpec.AR of the VAR(lag) model:
Spec = vgxset('n',6,'nAR',lag, 'Constant',true);
[EstSpec, ~, llh] = vgxvarx(Spec,coeff);

[~,bic] = aicbic(llh,vgxcount(EstSpec),size(coeff,1));

%evaluate the predicted coefficients of the VAR(lag) model, using the
%parameters EstSpec.a and EstSpec.AR
predCoeffVAR = evalCoeff(coeff,EstSpec.a,EstSpec.AR);

end

