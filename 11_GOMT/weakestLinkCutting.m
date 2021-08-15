function [Submodels] = weakestLinkCutting(Model)
%WEAKESTLINKCUTTING Summary of this function goes here
%   Detailed explanation goes here
sizeModel = size(Model,2);
dimSamples = zeros(sizeModel,1);
Submodels{1,1} = Model;
Submodels{2,1} = 0;
Tk = Model;
dimTree = size(Tk,2);
E_Delta = 0.0000001;

for i=1:sizeModel
    dimSamples(i) = size(Model(i).response,1);
end

%% Bestimmung der Weakest-Links
while dimTree > 1 % While-Schleife läuft so lange, bis nurnoch die Wurzel vorhanden ist
    
    alphaMin = 0; % Rücksetzen des Alpha-Wertes zur Ermittlung eines neuen Tk
    InfoPruning = [];
    
    %% Oberste Schleife, welche für jeden Nicht-Terminalknoten die Branch bestimmt
    for i=1:dimTree 
        
        if ~isempty(Tk(i).splitpoint) % aktueller Knoten ist kein Terminalknoten und kann gebrancht werden
            
            %% Auswahl neuer Wurzel
            Branch_Tk = [];
            Branch_Tk(1,:) = [Tk(i).note, Tk(i).parent];
            E_Parent = Tk(i).RMSE * dimSamples(i);
            E_ChildrenTerminal = 0;
            TerminalNotes_Branch = 0;
            
            %% Durchsuchung der Folgeknoten, ob diese der Wurzel E_Parent untergeordnet sind
            for i2=i+1:dimTree % Jeder Folgeknoten wird auf Branchzugehörigkeit geprüft
                
                buffer1 = [Tk(i2).note, Tk(i2).parent];
                
                %% Durchsuchen der bereits bestehenden Branch, ob aktueller Knoten Tk(i2) einen Vorfahren in der Branch hat und somit dieser zugehört
                for i3=1:size(Branch_Tk,1)
                    
                    if buffer1(2) == Branch_Tk(i3,1) % Kindsknoten wurde als Bestandtteil des Branches identifiziert
                        dimInfoPruning = size(Branch_Tk,1)+1;
                        Branch_Tk(dimInfoPruning,:) = buffer1;
                        
                        %% Kostenermittlung
                        if isempty(Tk(i2).splitpoint) % Knoten ist ein Terminalknoten
                            error = Tk(i2).RMSE * dimSamples(i2);
                            E_ChildrenTerminal = E_ChildrenTerminal+error;
                            TerminalNotes_Branch = TerminalNotes_Branch+1;
                        end
                    end
                end
            end
            
            %% Bestimmung dem zur Branch gehörenden Alpha-Wert
            alpha = (E_Parent - E_ChildrenTerminal)/(TerminalNotes_Branch-1);
            
            %% Mehrere Branches werden möglicherweise durch das gleiche Alpha gestutzt oder (in elseif) Branch mit neuem AlphaMin entdeckt
            if (alpha > (alphaMin - E_Delta)) && (alpha < (alphaMin + E_Delta)) % E-Delta ist zur Vermeidung von Rundungsfehlern
                
                dimInfoPruning = size(InfoPruning,2); % dimInfoPruning entspricht der Anzahl an Branches mit gleichem Alpha
                BranchInBranch = 0;
                
                %% Überprüfung, ob neu ermittelte Branch mit gleichem Alpha-Wert zur einer der zuvor ermittelten und in dimInfoPruning gesp. Branches zugehört
                for i2=1:dimInfoPruning
                    
                    buffer1 = InfoPruning{1,i2};
                
                    for i3=1:size(buffer1,1)
                        if Branch_Tk(1,1) == buffer1(i3,1)
                            BranchInBranch = 1;
                        end
                    end
                end
                 
                %% Aktuell ermittelte Branch ist zulässig
                if BranchInBranch == 0    
                    dimInfoPruning = dimInfoPruning+1;
                    InfoPruning{1,dimInfoPruning} =  Branch_Tk;
                end
                
            elseif (alpha < alphaMin) || (alphaMin == 0) % neue, als nächstes zu stutzende Branch ermittelt
                alphaMin = alpha;
                InfoPruning = [];
                InfoPruning{1,1} =  Branch_Tk;
            end
                 
        end
    end
    
    % Stutzen
    %% Substitution der Wahrscheinlichkeitswerte für den gestutzten Baum T1
    dimInfoPruning = size(InfoPruning,2);
    
    for i=1:dimInfoPruning
        buffer1 = InfoPruning{1,i};
        
        for i2=1:size(buffer1,1)
            exit = 0;
            i3 = 1;
            while exit == 0
                
                buffer2 = [Tk(i3).note, Tk(i3).parent];
                
                if (i2 == 1) && (buffer2(1) == buffer1(i2,1))
                    exit = 1;
                    Tk(i3).splitcrit = []; % löschen der Split-Info und deklarierung als Terminalknoten
                    Tk(i3).direction = [];
                    Tk(i3).splitpoint = [];
                    Tk(i3).splitratio = [];
                    
                elseif buffer2(1) == buffer1(i2,1)
                    exit = 1;
                    Tk(i3) = []; % Ganze zeile raus löschen
                    dimSamples(i3) = [];
                    
                else
                    i3 = i3+1;
                end       
            end
        end
    end
    
    %% Abspeichern des neu gestutzten Baumes Tk
    dimTK = size(Submodels,2)+1;
    Submodels{1,dimTK} = Tk;
    Submodels{2,dimTK} = alphaMin;

    dimTree = size(Tk,2);
    
end
end

