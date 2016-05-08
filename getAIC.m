function [ modelAIC ] = getAIC( model, thisObs )
%GETAIC evaluates the AIC for all possible models
%   columns 1-5 of the modelCriterion represent the 5 different models

modelAIC = zeros(1,size(model,1));
for ii = 1:size(model,1)
    a = model(ii,:)>0;
    thisModel = model(ii,a);
    thisModelXmatrix = getExplanVars(thisObs.Moneyness, thisObs.TimeToMaturity, thisModel);
    
    % fit model and extract coefficients
    mdl = LinearModel.fit(thisModelXmatrix,thisObs.implVol);    
    modelAIC(ii) = mdl.ModelCriterion.AIC;
end

end

