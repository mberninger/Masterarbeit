function [ bestModel, freqBestModel, bestModelAll, freqBestModelAll ] = get3DBestModel( gnOfFit, uniqueDates, nRep )
% GET3DBESTMODEL determines the model, which fits best on how many days for
% a 3-dimensional array gnOfFit
%   gnOfFit is a 3-dimensional array of size nRep x msize x nDates

%   bestModelForDay is a vector of size nDates and each row expresses which
%   model fits best at that day
%   bestModel is the column number of the model which fits best most often,
%   when the different days are looked at seperately
%   freqBestModel is the number of days the bestModel fits best, when the 
%   different days are looked at seperately

%   bestModelAll is the column number of the model which fits best most
%   often, when all gnOfFit measures are looked at without looking at
%   different days
%   freqBestModelAll is the number of days the bestModel fits best, when 
%   all gnOfFit measures are looked at without looking at different days

nDates = length(uniqueDates);
indexMSE = zeros(nDates,nRep);
bestModelForDay = zeros(nDates,1);

for ii = 1:nDates
    [ ~ , indexMSE(ii,:)] = min(gnOfFit(:,:,ii).');
    bestModelForDay(ii) = mode(indexMSE(ii,:));
end
[bestModel, freqBestModel] = mode(bestModelForDay);

% if the days are not looked at seperately, the best model is calculated
% in one step from all mse:
indexMSEAll = reshape(indexMSE,[],1);
[bestModelAll,freqBestModelAll] = mode(indexMSEAll);

end