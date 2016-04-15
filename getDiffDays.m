function [ dataPerDay ] = getDiffDays( date )
% getDiffDays ermittelt die Anzahl der Daten pro Tag
% Finde Datumswechsel
s = size(date);
s = s(1);
changeDay = ones(s,1);
for i = 2:s
    if date(i) == date (i-1)
        changeDay(i,1) = 0;
    else
        changeDay(i,1) = 1;
    end
end

changeDay = table(changeDay);

% Ermittle Zeilen in denen Datumswechsel stattfindet
rowNumber = ones(s,1);
for i = 2:s
    if changeDay.changeDay(i) == 1;
        rowNumber(i) = height(changeDay(1:i,1));
    else
        rowNumber (i) = 0;
    end
end

% Erfasse nur Werte ungleich 0
dataPerDay = rowNumber(rowNumber > 0);

end

