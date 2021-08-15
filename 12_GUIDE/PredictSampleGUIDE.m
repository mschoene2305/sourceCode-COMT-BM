function [y] = PredictSampleGUIDE(T,Sample,ModeX)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
SplitcritDefault = 0; %Variable zur Auswahl des Kindknotens mit der höchsten Samplewahrscheinlichkeit für fehlende MErkmale
i = 1;
Marker = 0;
exit = 0;
SplitcritFalse = 0;

while exit == 0

    StructureInfo = T{i,1}; % Knoteninformationen (Knotenindex, Parentindex)

    if Marker == StructureInfo(2)

        i = i+SplitcritFalse;

        %% Aufteilung in den Kindsknoten, wenn verfügbare eingangsvariable nicht verfügbar
        if SplitcritDefault 
            Propability_t1 = T{i,5};
            Propability_t2 = T{i+1,5};

            if Propability_t2(2) > Propability_t1(2) % Auswahl des Knotens, der während der Trainingsphase mehr Datensätze zugewiesen bekommen hat
                i = i+1;
            end

            SplitcritDefault = 0;
        end


        if size(T{i,2},2) == 0 % Knoten ist Terminalknoten
            exit = 1;
            y = T{i,4}*[1 Sample]';

        else % Split Knoten
            SplitcritFalse = 0;
            if sum(isnan(Sample(T{i,2}>0))) > 0 % Merkmal xm hat fehlenden Wert
                SplitcritDefault = 1;
                    
            else
                if length(T{i,3}) == 1 % numerisch
                    if (T{i,2}*Sample') <= T{i,3} % Sk trifft zu, nehme linken Knoten
                        SplitcritFalse = 0;
                        
                    else
                        SplitcritFalse = 1; % sonst rechten Knoten
                        
                    end

                else % kategorsch
                    sm = T{i,3};
                    SplitcritFalse = 1;
                    for i2=1:size(sm,2)
                        if Sample(T{i,2}>0) == sm(i2)

                            SplitcritFalse = 0;

                        end
                    end
                end
            end
                       
            StructureInfo = T{i,1};
            Marker = StructureInfo(1);

        end
    end

    i = i+1;

end 
end

