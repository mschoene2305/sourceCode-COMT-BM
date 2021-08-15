function [y] = predictSampleGOMT(tree,sample)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
splitcritDefault = 0; %Variable zur Auswahl des Kindknotens mit der höchsten Samplewahrscheinlichkeit für fehlende MErkmale
i = 1;
marker = 0;
exit = 0;
splitcritFalse = 0;

while exit == 0

    if marker == tree(i).parent

        i = i+splitcritFalse;

        %% Aufteilung in den Kindsknoten, wenn verfügbare eingangsvariable nicht verfügbar
        if splitcritDefault 

            if tree(i).splitratio < 0.5 % Auswahl des Knotens, der während der Trainingsphase mehr Datensätze zugewiesen bekommen hat
                i = i+1;
            end

            splitcritDefault = 0;
        end


        if isempty(tree(i).splitpoint) % Knoten ist Terminalknoten
            exit = 1;
            y = [1 sample]*tree(i).localModel;

        else % Split Knoten
            splitcritFalse = 0;
            if sum(isnan(sample(tree(i).splitcrit>0))) > 0 % Merkmal xm hat fehlenden Wert
                splitcritDefault = 1;
                    
            else
                if size(tree(i).splitcrit,2) == 1 % numerisch
                    if (sample*tree(i).splitcrit) <= tree(i).splitpoint % Sk trifft zu, nehme linken Knoten
                        splitcritFalse = 0;
                        
                    else
                        splitcritFalse = 1; % sonst rechten Knoten
                        
                    end

                else % kategorsch
                    %sm = tree{i,3};
                    %splitcritFalse = 1;
                    %for i2=1:size(sm,2)
                    %    if sample(tree{i,2}>0) == sm(i2)

                    %        splitcritFalse = 0;

                    %    end
                   % end
                end
            end
                       
            marker = tree(i).note;

        end
    end

    i = i+1;

end 
end

