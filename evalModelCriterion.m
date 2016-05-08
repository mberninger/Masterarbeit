function [ modelCriterion ] = evalModelCriterion( model, filteredData )
%EVALMODELCRITERION evaluates the modelCriterion for all days
%   the rows represent the different days, in which always 5
%   modelCriterions are listed for the 5 different models

uniqueDates = unique(filteredData.Date);
nDates = length(uniqueDates);
modelCriterion = zeros(nDates,5);

for ii = 1:nDates    
    thisDate = uniqueDates(ii);
    thisObs = getObs(thisDate,filteredData);
    
    modelCriterion(ii,:) = getAIC(model,thisObs);
end

end

