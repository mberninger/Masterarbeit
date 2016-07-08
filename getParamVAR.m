function [ param, bic ] = getParamVAR( coeff, lag )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

Spec = vgxset('n',6,'nAR',lag, 'Constant',true);
[EstSpec, ~, llh] = vgxvarx(Spec,coeff);

[~,bic] = aicbic(llh,vgxcount(EstSpec),size(coeff,1));

param = evalCoeffVar(coeff,EstSpec.a,EstSpec.AR);

end

