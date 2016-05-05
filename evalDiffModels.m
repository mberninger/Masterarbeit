function [ mse, rmse ] = evalDiffModels( model, dataInSample, dataOutOfSample )
%EVALDIFFMOGNOFFIT evaluates the mean squared and root mean squared error
%for the different models

mse = zeros(1,size(model,1));
rmse = zeros(1,size(model,1));
for ii = 1:size(model,1)
    a = model(ii,:)>0;
    thisModel = model(ii,a);
    coeffInSample = getCoeff(thisModel, dataInSample);
    
    vola = evalVola(dataOutOfSample, coeffInSample, thisModel);
    implVolaData = dataOutOfSample.implVol;
    
    mse(ii) = getMse(vola,implVolaData,length(vola));
    rmse(ii) = getRmse(vola,implVolaData,length(vola));
end


end

