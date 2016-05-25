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
    % You still fit the model only once with all data drawn from nReps
    % draws! If you have 200 observations, you have to fit the model on
    % 0.8*200=160 observations only, and evaluate it on the remaining
    % 0.2*200=40 observations, and repeat that nReps times.
    %
    % And NOT: fit the model on 0.8*200*nReps only once!
    
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

