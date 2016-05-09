function [ thisObs, thisObsSize ] = getObs( chosenDate, selectedData )
%GETOBS reduces the selected dataset to the chosen date
%   it gives back the dataset of the chosen date and the length of the dataset of
%   the chosen date

    thisObs = selectedData(selectedData.Date == chosenDate,:);
    % REMARK: searching entries with given date is costly, only do it once!
    thisObsSize = size(thisObs,1);

end

