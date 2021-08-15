function [Subtrees] = mccPruningFixedAlphaLSRT(Tcv, alphaSubtrees, samples)
%MXXPRUNINGFIXEDALPHA Summary of this function goes here
%   Detailed explanation goes here
sizeAlpha = size(alphaSubtrees,2);
sizeSamples = size(samples,1);
dimSamples = zeros(sizeSamples,1);
Subtrees = cell(1,sizeAlpha);
Subtrees{1,1} = Tcv;
E_Delta = 0.0000001;

%% Bestimmung der Anzahl an Datensätzen, die in jeden knoten fallen
for i=1:sizeSamples
    dimSamples(i) = size(samples{i,1},1);
end

for i=2:sizeAlpha
    %% Auswahl des Baumes, der mit dem neuen Alpha gestutzt werden soll
    currentTree = Subtrees{1,i-1};
    dimTree = size(currentTree,1);
    InfoPruning = [];
    
    %% Oberste Schleife, welche für jeden Nicht-Terminalknoten die Branch bestimmt
    for i2=1:dimTree 
        
        if size(currentTree{i2,2},2) > 0 % aktueller Knoten ist kein Terminalknoten und kann gebrancht werden
            
            %% Auswahl neuer Wurzel
            Branch_currentTree = [];
            Branch_currentTree(1,:) = currentTree{i2,1};
            E_Parent = NoteErrorLSRT(currentTree{i2,5},dimSamples(i2));
            E_ChildrenTerminal = 0;
            TerminalNotes_Branch = 0;
            
            %% Durchsuchung der Folgeknoten, ob diese der Wurzel E_Parent untergeordnet sind
            for i3=i2+1:dimTree % Jeder Folgeknoten wird auf Branchzugehörigkeit geprüft
                
                buffer1 = currentTree{i3,1};
                
                %% Durchsuchen der bereits bestehenden Branch, ob aktueller Knoten Tk(i2) einen Vorfahren in der Branch hat und somit dieser zugehört
                for i4=1:size(Branch_currentTree,1)
                    
                    if buffer1(2) == Branch_currentTree(i4,1) % Kindsknoten wurde als Bestandtteil des Branches identifiziert
                        dimInfoPruning = size(Branch_currentTree,1)+1;
                        Branch_currentTree(dimInfoPruning,:) = buffer1;
                        
                        %% Kostenermittlung
                        if size(currentTree{i3,2},2) == 0
                            error = NoteErrorLSRT(currentTree{i3,5},dimSamples(i3));
                            E_ChildrenTerminal = E_ChildrenTerminal+error;
                            TerminalNotes_Branch = TerminalNotes_Branch+1;
                        end
                    end
                end
            end
            
            %% Bestimmung dem zur Branch gehörenden Alpha-Wert
            alpha = (E_Parent - E_ChildrenTerminal)/(TerminalNotes_Branch-1);
            
            %% Mehrere Branches werden möglicherweise durch das gleiche Alpha gestutzt oder (in elseif) Branch mit neuem AlphaMin entdeckt
            if alpha < (alphaSubtrees(i) + E_Delta) % E-Delta ist zur Vermeidung von Rundungsfehlern
                
                dimInfoPruning = size(InfoPruning,2); % dimInfoPruning entspricht der Anzahl an Branches mit gleichem Alpha
                BranchInBranch = 0;
                
                %% Überprüfung, ob neu ermittelte Branch mit gleichem Alpha-Wert zur einer der zuvor ermittelten und in dimInfoPruning gesp. Branches zugehört
                for i3=1:dimInfoPruning
                    
                    buffer1 = InfoPruning{1,i3};
                
                    for i3=1:size(buffer1,1)
                        if Branch_currentTree(1,1) == buffer1(i3,1)
                            BranchInBranch = 1;
                        end
                    end
                end
                 
                %% Aktuell ermittelte Branch ist zulässig
                if BranchInBranch == 0    
                    dimInfoPruning = dimInfoPruning+1;
                    InfoPruning{1,dimInfoPruning} =  Branch_currentTree;
                end
            end
        end
    end
    
    %% Stutzen
    dimInfoPruning = size(InfoPruning,2);
    
    if dimInfoPruning > 0
        for i2=1:dimInfoPruning
            buffer1 = InfoPruning{1,i2};

            for i3=1:size(buffer1,1)
                exit = 0;
                i4 = 1;
                while exit == 0

                    buffer2 = currentTree{i4,1};

                    if (i3 == 1) && (buffer2(1) == buffer1(i3,1))
                        exit = 1;
                        currentTree{i4,2} = []; % löschen der Split-Info und deklarierung als Terminalknoten
                        currentTree{i4,3} = [];

                    elseif buffer2(1) == buffer1(i3,1)
                        exit = 1;
                        currentTree(i4,:) = []; % Ganze zeile raus löschen
                        dimSamples(i4) = [];

                    else
                        i4 = i4+1;
                    end       
                end
            end
        end
    end
    
    %% Abspeichern des neu gestutzten Baumes currentTree
    Subtrees{1,i} = currentTree;
    
    %%

end

end

