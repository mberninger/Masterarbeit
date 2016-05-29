function [ mse, rmse ] = evalDiffModels( model, dataInSample, dataOutOfSample, msize )
%EVALDIFFMODELS evaluates the mean squared and root mean squared error for
%a specific dataInSample and dataOutOfSample for all possible models
%   The different columns represent the different models

mse = zeros(1,msize);
rmse = zeros(1,msize);
for ii = 1:msize
    a = model(ii,:)>0;
    thisModel = model(ii,a);
    coeffInSample = getCoeff(thisModel, dataInSample); 
    
    vola = evalVola(dataOutOfSample, coeffInSample, thisModel);
    implVolaData = dataOutOfSample.implVol;
 
    mse(:,ii) = getMse(vola,implVolaData);
    rmse(:,ii) = getRmse(vola,implVolaData);
end

end

