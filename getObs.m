function [ thisObs, thisObsSize ] = getObs( chosenDate, selectedData )
%GETOBS reduces the selected dataset to the chosen date
%   it gives back the dataset of the chosen date and the length of the dataset of
%   the chosen date

    thisObsSize = size(selectedData(selectedData.Date == chosenDate,:),1);
    thisObs = selectedData(selectedData.Date == chosenDate,:);

end

