function [ mse, rmse ] = evalDiffModels( model, dataInSample, dataOutOfSample, nRep )
%EVALDIFFMODELS evaluates the mean squared and root mean squared error for
%a specific dataInSample and dataOutOfSample for all possible models
%   The different columns 1-5 represent the 5 different models
samp = size(dataOutOfSample,1)/nRep;
mse = zeros(nRep,size(model,1));
rmse = zeros(nRep,size(model,1));
for ii = 1:size(model,1)
    a = model(ii,:)>0;
    thisModel = model(ii,a);
    coeffInSample = getCoeff(thisModel, dataInSample);
    
    vola = evalVola(dataOutOfSample, coeffInSample, thisModel);
    implVolaData = dataOutOfSample.implVol;
    
    % evaluate the mse and rmse for every one of the nRep out-of-sample
    % permutated subsamples, which have the size "samp"
    for j=1:nRep
        mse(j,ii) = getMse(vola(j*samp-samp+1:j*samp),implVolaData(j*samp-samp+1:j*samp));
        rmse(j,ii) = getRmse(vola(j*samp-samp+1:j*samp),implVolaData(j*samp-samp+1:j*samp));
    end

end


end

