function [ sortedMSE, bestModelMSE, sortedRMSE, bestModelRMSE ] = getBestModel( mse, rmse )
%GETBESTMODEL determines the model, which fits best on how many days
%   indexMSE/indexRMSE is the column number of the model which fits best at the
%   specific day, bestModelMSE/bestModelRMSE is the cumulative number for
%   the frequency a model fits best

[ ~ , indexMSE] = min(mse.');
indexMSE = indexMSE.';
sortedMSE = sort(indexMSE);
[ ~ , bestModelMSE] = unique(sortedMSE,'rows');
bestModelMSE = [bestModelMSE; size(mse,1)+1];

[ ~ , indexRMSE] = min(rmse.');
indexRMSE = indexRMSE.';
sortedRMSE = sort(indexRMSE);
[ ~ , bestModelRMSE] = unique(sortedRMSE,'rows');
bestModelRMSE = [bestModelRMSE; size(mse,1)+1];

end
