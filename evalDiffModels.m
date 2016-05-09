function [ mse, rmse ] = evalDiffModels( model, dataInSample, dataOutOfSample )
%EVALDIFFMODELS evaluates the mean squared and root mean squared error for
%a specific dataInSample and dataOutOfSample for all possible models
%   The different columns 1-5 represent the 5 different models

mse = zeros(1,size(model,1));
rmse = zeros(1,size(model,1));
for ii = 1:size(model,1)
    a = model(ii,:)>0;
    thisModel = model(ii,a);
    coeffInSample = getCoeff(thisModel, dataInSample);
    
    vola = evalVola(dataOutOfSample, coeffInSample, thisModel);
    implVolaData = dataOutOfSample.implVol;
    
    mse(ii) = getMse(vola,implVolaData);
    rmse(ii) = getRmse(vola,implVolaData);
end


end

