function [PLST, NoteSamples] = buildLSRT(Eta, IC, Nmin, ModeX, train, localModelType, splitModelType)
%% Datensatz muss für den Algorithmus wie folgt aufbereitet sein:
%[x1  x2  x3  x4  .   .   . xM  Ausgabe]
% kategorische Variablen: Element von {0, 1, ..., M}
% nummerische Variablen: von +- unenedlich
%% Hyperparameter
% wenn EnableMulti == 1 ist, sind nur Multirvariate Kriterien erlaubt.
% wenn EnableMulti == 2 ist, sind Multivariate und Univariate Erlaubt
%% Die erzeugte Baumstruktur "Tcart" ist wie folgt geartet                                   
% Knoteninfo| Sel.-Krit. | local  | Err. Prop.|
% _t____tp__|_xm*_|__s*__|_Model__|__E_____%__|
%| 1    0   | xm  |  s   |  f(t)  | E(t)   .  |
%| 2    1   | xm  |  s   |  f(t)  | E(t)   .  |
%| .    .   | .   |  .   |   .    |  .     .  |
%| .    .   | .   |  .   |   .    |  .     .  |
%| .    .   | .   |  .   |   .    |  .     .  |
%|N-1 N-m-1 | 0   |  0   |  f(t)  |  .     .  |
%|_N___N-m__|_0___|__0___|__f(t)__|__._____.__|
% 
% t ist die Nr. des Knotens: geradzahlig tL, ungeradzahlig tR
% tp ist der Elternknoten t des aktuell besuchten Knotens
PLST               = cell(1,5);
%%                            VARIABLEN INTERN                            
% Index zur Erzeugung des Ausgangsarrays Tcart
it                  = 1;
% In den jeweiligen Knoten fallende Trainingssample
tSamples{1,1}       = cell(1,1);

%%                                  MAIN                                  
% -------------------------------------------------------------------------

%% SCHRITT 1: GRUNDINITIALISIERUNG

%%  Erzeugung Wurzel und Grundpopulation (Mittelwert von Y)
% Information der Anordnung im Baum (Index des eigenen Knotens und Index
% des Elternknotens
PLST{it,1} = [1 0];
% Datensätze im aktuellen Knoten
tSamples{1,1} = train;


%% SCHRITT 2: ITERTAIVES ERZEUGEN DES BAUMES
% Index it läuft bis zu size(Tcart,1) und detektiert somit ein Ende der Struktur
while it <= size(PLST,1)
    %% Preprocessing zur Analyse des aktuellen Knotens, ob geteilt oder terminalisiert werden soll
    %tSamples{it,1};        
    [NoteTerminal,predictors,response,alpha,beta] = PreprocessingDataLSRT(tSamples{it,1},ModeX,Nmin,Eta,IC,splitModelType);
    
    %% Erzeugen der nächsten binären Kindsknoten, wenn t ~= Terminalknoten
    if NoteTerminal == 0 

        %% Bestimmen des Primär-Splits
        [dataLeftNode,dataRightNode,N,alpha,threshold] = SplitDataLSRTc(1,alpha,ModeX,predictors,response);

        %% Erzeugung der Kindsknoten
        sizeTree = size(PLST,1);
        PLST{(sizeTree+1),1} = [(sizeTree+1), it];
        PLST{(sizeTree+1),5} = size(dataLeftNode,1)/N;
        PLST{(sizeTree+2),1} = [(sizeTree+2), it];
        PLST{(sizeTree+2),5} = size(dataRightNode,1)/N;
        samples2Split = tSamples{it,1};
        tSamples{sizeTree+1,1} = samples2Split(dataLeftNode,:);
        tSamples{sizeTree+2,1} = samples2Split(dataRightNode,:);

        %% Übergabe des Primärsplits s*
        PLST{it,2} = alpha;
        PLST{it,3} = threshold; 
    end
        [crap, parentNodeError] = SquaredErrorLSRT(response,size(response,1));
        if localModelType == 'CART'
            PLST{it,4} = [mean(response) zeros(1,size(ModeX,2))];
            PLST{it,5} = [parentNodeError PLST{it,5}];
        else
            PLST{it,4} = beta(1,:);
            PLST{it,5} = [parentNodeError PLST{it,5}];
        end
    
    %% Wechsel zum nächsten Knoten
    it = it+1;
end

NoteSamples = tSamples;
end

