function [ dataCallPerm, evalStart, evalStop, inSample ] = getRandSubsample( k, chosenData, dayChanges )
%GETRANDSUBSAMPLE permutates the chosenData for every day and gives it back
%in "dataCallPerm"
%   k describes the partial of the data das is used of out-of-sample
%   fitting
%   Furthermore the gives back the evaluation area for a subsample

randData = zeros(size(chosenData,1),1);
inSample = zeros(length(dayChanges)-1,1);
evalStart = zeros();
evalStop = zeros();
for i = 1:length(dayChanges)-1
    nbOfDays = dayChanges(i+1)-dayChanges(i);
    randData(dayChanges(i):dayChanges(i+1)-1,1) = (dayChanges(i)-1 + randperm(nbOfDays)).';
%     randData(dayChanges(i):dayChanges(i+1)-1,1) = permDays.';
    
    inSample(i,1) = round(nbOfDays*k);
    evalStart(i) = dayChanges(i);
    evalStop(i) = dayChanges(i)+inSample(i)-1;
    
end
clear i;

%% now get data table in different, permutated order
dataCallPerm = chosenData(randData, :);

end

