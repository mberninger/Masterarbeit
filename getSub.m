function [ dataInSample, dataOutOfSample ] = getSub( thisObsSize, selectedData, kPerc )
%GETSUB evaluates one permutated dataset of this observation and seperates
% it in an out-of-sample and an in sample dataset

% get permutated row number for this observation
randData = randperm(thisObsSize).';

% get inSample number for this observation
inSampleValue = round(kPerc*thisObsSize);
% seperate permutated dataset randData into inSample dataset and out of 
% sample dataset, the in sample dataset has length inSampleValue, the out
% of sample dataset is the rest
dataInSample = selectedData(randData(1:inSampleValue,:),:);
dataOutOfSample = selectedData(randData((inSampleValue+1):thisObsSize,:),:);

end

