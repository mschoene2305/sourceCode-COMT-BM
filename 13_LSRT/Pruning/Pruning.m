function [TK,Tmin] = Pruning(T,Dtest,ModeX,A_priori)
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

%% Stutzen der Terminalknoten, für die E(tparent) = E(tChildLeft)+E(tChildRight) gilt
i = 1;
while Break == 0 % Break wird True, wenn Tk ohne Stutzen durchlaufen wurde
    
    Info_t = Tk{i,1};
    Info_tnext = Tk{i+1,1};
    
    if (size(Tk{i,2},2) == 0) && (size(Tk{i+1,2},2) == 0) && (Info_t(1,2) == Info_tnext(1,2)) % Terminalknoten-Paar detektiert
        E_ChildrenTerminal = Tk{i,3}+Tk{i+1,3};
        i2 = dimTree-1;
        
        Info_parent = Tk{i2,1};
        while Info_parent(1,1) ~= Info_t(1,2) % Ermittlung des Elternknotens
            i2 = i2-1;
            Info_parent = Tk{i2,1};
        end
        
        if (Tk{i2,3} <= (E_ChildrenTerminal + E_Delta)) && (dimInfoPruning == 0)

            InfoPruning = [i2, i]; %Abspeichern der zu stutzenden Knoten
            dimInfoPruning = size(InfoPruning,2);
            i = i+1;
            
        end
    end
    
    if (i >= (dimTree-1)) && (dimInfoPruning == 0)
        Break = 1;
    elseif dimInfoPruning > 0
        % Stutzen der gespeicherten Terminalknoten
        Tk{InfoPruning(1),2} = [];
        Tk(InfoPruning(2),:) = [];
        Tk(InfoPruning(2),:) = [];
        %
        i = 1; %Rücksetzen von i
        InfoPruning = []; %Rücksetzen der Prunning-Info
        dimInfoPruning = 0;
        dimTree = size(Tk,1);
    else
        i = i+1;
    end
    
end

%% Substitution der Wahrscheinlichkeitswerte für den gestutzten Baum T1
[TkOut] = Transformation(T,Tk);
[Etest] = DetermineError(TkOut,Dtest,ModeX,Lambda_ij);
TK{1,1} = TkOut;
TK{2,1} = 0;
TK{3,1} = Etest;

%% Bestimmung der Weakest-Links
dimTree = size(Tk,1);
while dimTree > 1
    
    alphaMin = 0;
    InfoPruning = [];
    
    for i=1:dimTree % oberste Schleife, welche die Branch für jeden Nicht-Terminalknoten durchsucht
        if size(Tk{i,2},2) > 0 % aktueller Knoten ist kein Terminalknoten und kann gebrancht werden
            
            Branch_Tk = [];
            Branch_Tk(1,:) = Tk{i,1};
            E_Parent = Tk{i,3};
            E_ChildrenTerminal = 0;
            TerminalNotes_Branch = 0;
            
            for i2=i+1:dimTree % Jeder Folgeknoten wird auf Branchzugehörigkeit geprüft
                
                buffer1 = Tk{i2,1};
                
                for i3=1:size(Branch_Tk,1)
                    
                    if buffer1(2) == Branch_Tk(i3,1) % Kindsknoten wurde als Bestandtteil des Branches identifiziert
                        dimInfoPruning = size(Branch_Tk,1)+1;
                        Branch_Tk(dimInfoPruning,:) = buffer1;
                        
                        if size(Tk{i2,2},2) == 0
                            E_ChildrenTerminal = E_ChildrenTerminal+Tk{i2,3};
                            TerminalNotes_Branch = TerminalNotes_Branch+1;
                        end
                    end
                end
            end
            
            alpha = (E_Parent - E_ChildrenTerminal)/(TerminalNotes_Branch-1);
            
            if (alpha > (alphaMin - E_Delta)) && (alpha < (alphaMin + E_Delta))
                
                dimInfoPruning = size(InfoPruning,2);
                BranchInBranch = 0;
                
                for i2=1:dimInfoPruning
                    
                    buffer1 = InfoPruning{1,i2};
                
                    for i3=1:size(buffer1,1)
                        if Branch_Tk(1,1) == buffer1(i3,1)
                            BranchInBranch = 1;
                        end
                    end
                end
                    
                if BranchInBranch == 0    
                    dimInfoPruning = dimInfoPruning+1;
                    InfoPruning{1,dimInfoPruning} =  Branch_Tk;
                end
                
            elseif (alpha < alphaMin) || (alphaMin == 0)
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
    
    [TkOut] = Transformation(T,Tk);
    [Etest] = DetermineError(TkOut,Dtest,ModeX,Lambda_ij);
    dimTK = size(TK,2)+1;
    TK{1,dimTK} = TkOut;
    TK{2,dimTK} = alphaMin;
    TK{3,dimTK} = Etest;
    
    dimTree = size(Tk,1);
    
end

%% Auswahl des Unterbaumes, mit dem niedrigsten Etest
buffer1 = TK{3,1};
Tmin = TK{1,1};
for i=1:size(TK,2)
   if TK{3,i} <= buffer1
       
       buffer1 = TK{3,i};
       Tmin = TK{1,i};
       
   end
end

