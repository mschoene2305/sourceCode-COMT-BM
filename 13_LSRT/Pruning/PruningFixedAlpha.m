function [T_pruned] = PruningFixedAlpha(T_base, T_unpruned, AlphaFixed)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
T_transformed = T_unpruned;
dimTree = size(T_unpruned,1);
dimClass = size(T_unpruned{1,3},2)-1;
Info_t = []; % Parent- und Childinfos
Info_tnext = []; % Parent- und Childinfos des Folgeknotens von Info_t
Info_parent = []; % Parent- und Childinfos des Wurzelknotens einer Branch
E_ChildrenTerminal = 0; % Kosten durch Terminalknoten einer Branch
E_Delta = 0.0000001; % zur Vermeidung von Rundungsfehlern
Branch_T = []; % Informationen eines Teilbaums/Branch mit erstem Element als Wurzel
dimInfoPruning = 0; % Zwischenspeicher zur Dimensionsermittlung verschiedener Branches oder Tupel von Branches 
TerminalNotes_Branch = 0; % Anzahl Terminalknoten einer Branch
InfoPruning = []; % Zu stutzende Knoten

%% Ermittlung der Fehlklassifikationskosten eines jeden Knotens innerhalb von T
for i=1:dimTree 
    buffer1 = 0;
    P = T_unpruned{i,3};

    for i2=1:dimClass % Bestimmen P(cj|t) -> max
        if P(i2) > buffer1
            buffer1 = P(i2);
        end
    end

    T_transformed{i,3} = (1 - buffer1)*P(i2+1);
end



%% Stutzen des Baumes
if AlphaFixed == 0 % weil Alpha = 0 nur Zusammenfassen des Baumes für E(tParent) = E(tChildLeft)+E(tChildRight)
    Break = 0;
    i = 1;
    while Break == 0 % Break wird True, wenn Tk ohne Stutzen durchlaufen wurde

        %% Wenn der ite Knoten Terminalknoten ist, haben Info_t und Info_tnext gleichen Vorfahren
        Info_t = T_transformed{i,1};
        Info_tnext = T_transformed{i+1,1};

        %% Überprüfung, ob Info_t und Info_tnext ein Terminalknotenpaar bilden
        if (size(T_transformed{i,2},2) == 0) && (size(T_transformed{i+1,2},2) == 0) && (Info_t(1,2) == Info_tnext(1,2))

            E_ChildrenTerminal = T_transformed{i,3}+T_transformed{i+1,3}; % Kostenbestimmung der zum Pfad gehörenden Terminalknoten
            i2 = dimTree-1; % i2 wird auf den vorletzten Knoten des Baumes gesetzt
            Info_parent = T_transformed{i2,1};

            %% Ermittlung des Elternknotens: Reversiewe Durchsuchung des Baumes
            while Info_parent(1,1) ~= Info_t(1,2) 
                i2 = i2-1; % Index auf Knoten höherer Ebene legen
                Info_parent = T_transformed{i2,1};
            end

            %% Überprüfung, ob R(tParent) = R(tChildren) gilt
            if (T_transformed{i2,3} <= (E_ChildrenTerminal + E_Delta)) && (dimInfoPruning == 0)

                InfoPruning = [i2, i]; %Abspeichern der zu stutzenden Knoten
                dimInfoPruning = size(InfoPruning,2);
                i = i+1;

            end
        end

        %% Überprüfung, ob der Komplette Baum T vollständig gestutzt wurde (ob Anforderungen an T0 genügen)
        if (i >= (dimTree-1)) && (dimInfoPruning == 0) % Baum vollständig gestutzt
            Break = 1;
        elseif dimInfoPruning > 0 % Baum muss weiter um die zuvor ermitelten Knoten gestutzt werden
            % Stutzen der gespeicherten Terminalknoten
            T_transformed{InfoPruning(1),2} = [];
            T_transformed(InfoPruning(2),:) = [];
            T_transformed(InfoPruning(2),:) = [];
            i = 1; %Rücksetzen von i
            InfoPruning = []; %Rücksetzen der Prunning-Info
            dimInfoPruning = 0;
            dimTree = size(T_transformed,1);
        else % Baum ist noch nicht zu Ende durchwandert und es wurden keine zu stutzende Knoten detektiert
            i = i+1;
        end

    end

    %% Substitution der Wahrscheinlichkeitswerte für den gestutzten Baum
    [T_pruned] = Transformation(T_base, T_transformed);   
    
    
    
    
    
    
else % Stutzen für einen defineirten Alpha-Wert, der größer 0 ist
%% Oberste Schleife, welche für jeden Nicht-Terminalknoten die Branch bestimmt
    for i=1:dimTree 
        
        if size(T_transformed{i,2},2) > 0 % aktueller Knoten ist kein Terminalknoten und kann gebrancht werden
            
            %% Auswahl neuer Wurzel
            Branch_T = [];
            Branch_T(1,:) = T_transformed{i,1};
            E_Parent = T_transformed{i,3};
            E_ChildrenTerminal = 0;
            TerminalNotes_Branch = 0;
            
            %% Durchsuchung der Folgeknoten, ob diese der Wurzel E_Parent untergeordnet sind
            for i2=i+1:dimTree % Jeder Folgeknoten wird auf Branchzugehörigkeit geprüft
                
                buffer1 = T_transformed{i2,1};
                
                %% Durchsuchen der bereits bestehenden Branch, ob aktueller Knoten T_transformed(i2) einen Vorfahren in der Branch hat und somit dieser zugehört
                for i3=1:size(Branch_T,1)
                    
                    if buffer1(2) == Branch_T(i3,1) % Kindsknoten wurde als Bestandtteil des Branches identifiziert
                        % Anfügen des neuen Knotens 
                        dimInfoPruning = size(Branch_T,1)+1; 
                        Branch_T(dimInfoPruning,:) = buffer1;
                        
                        %% Kostenermittlung
                        if size(T_transformed{i2,2},2) == 0 % neu angefügter Knoten ist Terminalknoten
                            E_ChildrenTerminal = E_ChildrenTerminal+T_transformed{i2,3};
                            TerminalNotes_Branch = TerminalNotes_Branch+1;
                        end
                    end
                end
            end
            
            %% Bestimmung dem zur Branch gehörenden Alpha-Wert
            alpha = (E_Parent - E_ChildrenTerminal)/(TerminalNotes_Branch-1);
            
            %% Alpha der aktuellen Branch unterschreitet AlphaFixed
            if (alpha + E_Delta) < AlphaFixed  % E-Delta ist zur Vermeidung von Rundungsfehlern
                
                dimInfoPruning = size(InfoPruning,2); % dimInfoPruning entspricht der Anzahl an Branches für die Alpha < AlphMin gilt
                
                if dimInfoPruning > 0 % Es wurde bereits eine Branch zum Stutzen ermittelt und neue Branch muss hinzu gefügt werden
                    BranchInBranch = 0;

                    %% Überprüfung, ob neu ermittelte Branch mit gleichem Alpha-Wert zur einer der zuvor ermittelten und in dimInfoPruning gesp. Branches zugehört
                    for i2=1:dimInfoPruning

                        buffer1 = InfoPruning{1,i2};

                        for i3=1:size(buffer1,1)
                            if Branch_T(1,1) == buffer1(i3,1)
                                BranchInBranch = 1;
                            end
                        end
                    end

                    %% Aktuell ermittelte Branch ist zulässig
                    if BranchInBranch == 0    
                        dimInfoPruning = dimInfoPruning+1;
                        InfoPruning{1,dimInfoPruning} =  Branch_T;
                    end
                
                else % es wurde eine Branch ermittelt, dessen Kosten unterhalb von AlphaFixed liegen
                    InfoPruning = [];
                    InfoPruning{1,1} =  Branch_T;
                end
            end       
        end
    end
    
    % Stutzen
    %% Stutzen des Baumes 
    dimInfoPruning = size(InfoPruning,2);
    
    for i=1:dimInfoPruning
        buffer1 = InfoPruning{1,i};
        
        for i2=1:size(buffer1,1)
            exit = 0;
            i3 = 1;
            while exit == 0
                
                buffer2 = T_transformed{i3,1};
                
                if (i2 == 1) && (buffer2(1) == buffer1(i2,1))
                    exit = 1;
                    T_transformed{i3,2} = []; % Löschen der Split-Info und Deklarierung als Terminalknoten
                    
                elseif buffer2(1) == buffer1(i2,1)
                    exit = 1;
                    T_transformed(i3,:) = []; % Ganze zeile raus löschen
                    
                else
                    i3 = i3+1;
                end       
            end
        end
    end
    
    %% Substitution der Wahrscheinlichkeitswerte für den gestutzten Baum
    [T_pruned] = Transformation(T_base, T_transformed);      
end

