% Aktuelle Baumstruktur Tk wird in einer for-schleife iterativ
% durchwandert. Dabei wird für jeden Knoten, der duchwandert wird, der
% Kostenfaktor Etrain(t) sowie der Kostenfaktor Etrain(Tt) des aus dem 
% Knoten t resultierenden Unterbaums (mit t als Wurzel) bestimmt. Daraus
% wird der Alpha-Wert ermittelt, ab dem der Folgebaum Tt mittelst minimum
% cost prunning ausgeästet werden müsste.
% TK ist ein Zell-Array 3xK
TK = [];
dimTK = 0;
Tk = T;
TkOut = [];
Branch_Tk = [];
BranchInBranch = 0;
TerminalNotes_Branch = 0;
Branch_Tk_aplha = [];
alpha = 0;
alphaMin = 0;
dimTree = size(T,1);
dimClass = size(T{1,3},2)-1;
P = cell(1,3);
P_terminal = 0;
InfoPruning = [];
dimInfoPruning = size(InfoPruning,2);
buffer1 = 0;
buffer2 = 0;
E_ChildrenTerminal = 0;
E_Parent = 0;
Etest = 0;
E_Delta = 0.0000001; % zur Vermeidung von Rundungsfehlern
Info_t = 0;
Info_tnext = 0;
Info_parent = 0;
Break = 0;

%% Ermittlung der Fehlklassifikationskosten eines jeden Knotens innerhalb von T
for i=1:dimTree 
    buffer1 = 0;
    P = T{i,3};

    for i2=1:dimClass % Bestimmen P(cj|t) -> max
        if P(i2) > buffer1
            buffer1 = P(i2);
        end
    end

    Tk{i,3} = (1 - buffer1)*P(i2+1);
end

%% Stutzen der Terminalknoten, für die E(tParent) = E(tChildLeft)+E(tChildRight) gilt
i = 1;
while Break == 0 % Break wird True, wenn Tk ohne Stutzen durchlaufen wurde
    
    %% Wenn der ite Knoten Terminalknoten ist, haben Info_t und Info_tnext gleichen Vorfahren
    Info_t = Tk{i,1};
    Info_tnext = Tk{i+1,1};
    
    %% Überprüfung, ob Info_t und Info_tnext ein Terminalknotenpaar bilden
    if (size(Tk{i,2},2) == 0) && (size(Tk{i+1,2},2) == 0) && (Info_t(1,2) == Info_tnext(1,2))
        
        E_ChildrenTerminal = Tk{i,3}+Tk{i+1,3}; % Kostenbestimmung der zum Pfad gehörenden Terminalknoten
        i2 = dimTree-1; % i2 wird auf den vorletzten Knoten des Baumes gesetzt
        Info_parent = Tk{i2,1};
        
        %% Ermittlung des Elternknotens: Reversiewe Durchsuchung des Baumes
        while Info_parent(1,1) ~= Info_t(1,2) 
            i2 = i2-1; % Index auf Knoten höherer Ebene legen
            Info_parent = Tk{i2,1};
        end
        
        %% Überprüfung, ob R(tParent) = R(tChildren) gilt
        if (Tk{i2,3} <= (E_ChildrenTerminal + E_Delta)) && (dimInfoPruning == 0)

            InfoPruning = [i2, i]; %Abspeichern der zu stutzenden Knoten
            dimInfoPruning = size(InfoPruning,2);
            i = i+1;
            
        end
    end
    
    %% Überprüfung, ob der Komplette Baum Tk vollständig gestutzt wurde (ob Anforderungen an T0 genügen)
    if (i >= (dimTree-1)) && (dimInfoPruning == 0) % Baum vollständig gestutzt
        Break = 1;
    elseif dimInfoPruning > 0 % Baum muss weiter um die zuvor ermitelten Knoten gestutzt werden
        % Stutzen der gespeicherten Terminalknoten
        Tk{InfoPruning(1),2} = [];
        Tk(InfoPruning(2),:) = [];
        Tk(InfoPruning(2),:) = [];
        i = 1; %Rücksetzen von i
        InfoPruning = []; %Rücksetzen der Prunning-Info
        dimInfoPruning = 0;
        dimTree = size(Tk,1);
    else % Baum ist noch nicht zu Ende durchwandert und es wurden keine zu stutzende Knoten detektiert
        i = i+1;
    end
    
end

%% Substitution der Wahrscheinlichkeitswerte für den gestutzten Baum T1 und Abspeichern des gestutzten Baumes 
[TkOut] = Transformation(T,Tk);
TK{1,1} = TkOut;
TK{2,1} = 0;

%% Bestimmung der Weakest-Links
dimTree = size(Tk,1);
while dimTree > 1 % While-Schleife läuft so lange, bis nurnoch die Wurzel vorhanden ist
    
    alphaMin = 0; % Rücksetzen des Alpha-Wertes zur Ermittlung eines neuen Tk
    InfoPruning = [];
    
    %% Oberste Schleife, welche für jeden Nicht-Terminalknoten die Branch bestimmt
    for i=1:dimTree 
        
        if size(Tk{i,2},2) > 0 % aktueller Knoten ist kein Terminalknoten und kann gebrancht werden
            
            %% Auswahl neuer Wurzel
            Branch_Tk = [];
            Branch_Tk(1,:) = Tk{i,1};
            E_Parent = Tk{i,3};
            E_ChildrenTerminal = 0;
            TerminalNotes_Branch = 0;
            
            %% Durchsuchung der Folgeknoten, ob diese der Wurzel E_Parent untergeordnet sind
            for i2=i+1:dimTree % Jeder Folgeknoten wird auf Branchzugehörigkeit geprüft
                
                buffer1 = Tk{i2,1};
                
                %% Durchsuchen der bereits bestehenden Branch, ob aktueller Knoten Tk(i2) einen Vorfahren in der Branch hat und somit dieser zugehört
                for i3=1:size(Branch_Tk,1)
                    
                    if buffer1(2) == Branch_Tk(i3,1) % Kindsknoten wurde als Bestandtteil des Branches identifiziert
                        dimInfoPruning = size(Branch_Tk,1)+1;
                        Branch_Tk(dimInfoPruning,:) = buffer1;
                        
                        %% Kostenermittlung
                        if size(Tk{i2,2},2) == 0
                            E_ChildrenTerminal = E_ChildrenTerminal+Tk{i2,3};
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
                
                buffer2 = Tk{i3,1};
                
                if (i2 == 1) && (buffer2(1) == buffer1(i2,1))
                    exit = 1;
                    Tk{i3,2} = []; % löschen der Split-Info und deklarierung als Terminalknoten
                    
                elseif buffer2(1) == buffer1(i2,1)
                    exit = 1;
                    Tk(i3,:) = []; % Ganze zeile raus löschen
                    
                else
                    i3 = i3+1;
                end       
            end
        end
    end
    
    %% Abspeichern des neu gestutzten Baumes Tk
    [TkOut] = Transformation(T,Tk);
    dimTK = size(TK,2)+1;
    TK{1,dimTK} = TkOut;
    TK{2,dimTK} = alphaMin;
    
    %%
    dimTree = size(Tk,1);
    
end