function [ start, stop, sizeDate ] = getRowsOfDate( filteredData, JJJJ, MM, DD )
%GETROWSOFDATE evaluates the row numbers of the start, end and length of 
% the date 'JJJJ-MM-DD' in the dataset filteredData, 

filteredData.DayNb = [1:size(filteredData,1)]';
dayVector = filteredData.DayNb(filteredData.Date == datenum(JJJJ, MM, DD),:);
sizeDate = length(dayVector);
start = dayVector(1);
stop = dayVector(end);

end

