function [SubLSRT, LSRT] = PrunedLSRT(dimCV, Enable1SE, Eta, IC, Nmin, ModeX, train, localModelType, splitModelType)
%PRUNEDCART Summary of this function goes here
%   Detailed explanation goes here

%% Training des Hauptbaumes
[LSRT, NoteSamples] = buildLSRT(Eta, IC, Nmin, ModeX, train, localModelType, splitModelType);

%% Enable des Prunings, indem der Eingabewert dimCV > 0 ist
if dimCV > 0
    %% Initialisierung der Eingangsgrößen
    
    %% Stutzen des Hauptbaumes
    sizeNoteSamples = size(NoteSamples,1);
    dimSamples = zeros(sizeNoteSamples,1);
    for i=1:sizeNoteSamples
        dimSamples(i) = size(NoteSamples{i,1},1);
    end
      
    SubLSRT = mccPruningLSRT(LSRT,dimSamples); 
    
    
    %% Erzeugung der CV-Datensätze und Training von CV Regressionsbäumen
    %DataCV = cell(1,dimCV);
    [TestCV, TrainCV, dimCV] = determineDatasetCvLSRT(dimCV, train);
    
    Tcv = cell(1,dimCV);
    for i=1:dimCV
    %parfor i=1:dimCV
        [Tcv{1,i}, cvNoteSamples{1,i}] = buildLSRT(Eta, IC, Nmin, ModeX, TrainCV{i}, localModelType, splitModelType);
    end
    
    %% Stutzen der CV Bäume mit fixem Alpha
    % Bestimmung der Alpha-Werte, mit denen gestutzt werden soll
    alphaSubtrees = cell2mat(SubLSRT(2,:));
    alphaCV = zeros(1,(size(alphaSubtrees,2)));
    for i=1:size(alphaCV,2)-1
        alphaCV(i) = sqrt(alphaSubtrees(i)*alphaSubtrees(i+1));
    end
    alphaCV(end) = alphaSubtrees(end) + (alphaSubtrees(end)-alphaCV(end-1));
    
    % Stutzen der Validierungsbäume
    cvSubtrees = cell(1,size(Tcv,2));
    for i=1:size(Tcv,2)
    %parfor i=1:size(Tcv,2)
        cvSubtrees{1,i} = mccPruningFixedAlphaLSRT(Tcv{1,i}, alphaCV, cvNoteSamples{1,i});
    end
 
    %% Identifikation
    indexSubtrees = optimalComplexityLSRT(cvSubtrees, TestCV, ModeX, Enable1SE);
    
    %% Auswahl des optimalen Unterbaumes aus "Subtrees"
    LSRT = SubLSRT{1,indexSubtrees};
end

