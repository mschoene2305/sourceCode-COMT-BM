function [y, E] = SquaredErrorLSRT(data,dataSizeError)
% Baustein zur Bestimmung des Ausgangswertes eines Knotens und des Fehlers
% Wenn der Fehler der zwei Kindsknoten zur Splitbestimmung ermittelt werden
% soll, entspricht die Eingangsgröße "dataSizeError" der Datensatzanzahl im
% Elternknoten
dataSize = size(data,1);
y = 0;
E = 0;

for i1=1:dataSize
    y = y+data(i1,1);
end
y = y/dataSize; % Bestimmen des Mittelwertes

for i1=1:dataSize
    E = E + (data(i1,1) - y)^2;
end
E = E/dataSizeError; % Bestimmen des Fehlers

end

