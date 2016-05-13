function [ dataInSample, dataOutOfSample ] = getSub( thisObsSize, selectedData, nRep, kPerc )
%GETSUB evaluates permutated out-of-sample and in sample dataset
%   

% get permutated row number for this observation, repeated nRep-times
% 
% mse = zeros(nRep,size(allModels,1));
% rmse = zeros(nRep,size(allModels,1));
randData = zeros(thisObsSize,nRep);
for ii=1:nRep
randData(:,ii) = randperm(thisObsSize).';
end
% get inSample number for this observation
inSampleTest = round(kPerc*thisObsSize);
% get dataset only for the inSample row numbers and the outOfSample row
% numbers, the different columns from randData are put underneath
dataInSample = selectedData(randData(1:inSampleTest,:),:);
dataOutOfSample = selectedData(randData((inSampleTest+1):thisObsSize,:),:);

% [mse(ii,:), rmse(ii,:)] = evalDiffModels(allModels,dataInSample,dataOutOfSample);

end

