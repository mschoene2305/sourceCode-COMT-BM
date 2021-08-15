function [dataLeftNode,dataRightNode,N,alpha,threshold] = SplitDataPLST(Splitmode,alpha,ModeX,predictors,response)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

M = size(ModeX,2);
N = size(response,1);
maskCategoricals = ModeX(ModeX==0);

if Splitmode == 1 % Splitmode, der nach CART-Kriterien teilt
    % Sortieren der numerischen (transformierten) Eingangsgröße und
    % Bestimmung univariaten Split
    [sortedPredictors,orderForDataset] = sort(predictors(:,1));
    sortedResponse = response(orderForDataset);
    [crap, parentNodeError] = SquaredError(sortedResponse,N);
    deltaErrorBest = 0;
    splitPoint = 0;
    
    for i=1:N
        %% Bestimmen delta error und Erhöhen des Schwellwertes
        [crap, leftNodeError] = SquaredError(sortedResponse(1:i),N);
        [crap, rightNodeError] = SquaredError(sortedResponse((i+1):N),N);
        deltaError = parentNodeError - leftNodeError - rightNodeError;

        % Delta error ist null
        if deltaError < 0 % für Vermeidung von Rundungsfehlern,
            deltaError = 0;
        end

        % neuer besserer Split gefunden
        if ((deltaError >= deltaErrorBest) && ~isnan(deltaError))
            splitPoint = i;
            deltaErrorBest = deltaError;
        end
    end
    
    
    % Überprüfung, ob es auch kategorische Größen gibt
    if maskCategoricals > 0
        for i=1:size(maskCategoricals,2)
            catSplit = maskCategoricals(i);
            % predictors(i+1) wird auf einen kategorischen Split hin
            % untersucht
        end
    end 
    
    if splitPoint == 0 % es konnte kein Split ermittelt werden
        alpha = zeros(1,M);
        dataLeftNode = 0;
        dataRightNode = 0;
        threshold = 0;
    elseif size(splitPoint,2) == 1 && splitPoint > 0 && splitPoint < N % numerischer Split
        dataLeftNode = orderForDataset(1:splitPoint);
        dataRightNode = orderForDataset((splitPoint+1):end);
        threshold = sortedPredictors(splitPoint)+(sortedPredictors(splitPoint+1)-sortedPredictors(splitPoint))/2;    
    elseif size(splitPoint,2) > 1 % kategorischer Split
        alpha = zeros(1,M);
        alpha(maskCategoricals(catSplit)) = 1;
        dataLeftNode = 0;
        dataRightNode = 0;
        threshold = splitPoint;
    else % fehler
        error("Uncorrect Splitpoint is detected")
    end
    
else
    error("Splitmode is not available")
end
end

