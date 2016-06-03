function [ bestModel, freqBestModel, indexMSE ] = getBestModel( gnOfFit )
%GETBESTMODEL determines the model, which fits best on how many days
%   bestModel is the column number of the model which fits best most often,
%   freqBestModel is the number of days the bestModel fits best

[ ~ , indexMSE] = min(gnOfFit.');
indexMSE = indexMSE.';
[bestModel, freqBestModel] = mode(indexMSE);

end
