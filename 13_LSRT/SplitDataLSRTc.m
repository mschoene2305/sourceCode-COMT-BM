function [dataLeftNode,dataRightNode,N,alpha,threshold] = SplitDataLSRTc(Splitmode,alpha,ModeX,predictors,response,dimensionZ)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

M = size(ModeX,2);
N = size(response,1);
dimensionZ = size(alpha,1);
maskCategoricals = ModeX(ModeX==0);

if Splitmode == 1 % Splitmode, der nach CART-Kriterien teilt
    % Sortieren der numerischen (transformierten) Eingangsgröße und
    [sortedPredictors,orderForDataset] = sort(predictors(:,1:dimensionZ));
    % Bestimmung univariaten Split
    deltaErrorBest = 0;
    splitPoint = 0;
    dimension = 0;

    for k=1:dimensionZ
        sortedResponse = response(orderForDataset(:,k));
        for i=1:N
            %% Bestimmen delta error und Erhöhen des Schwellwertes
            [crap, parentNodeError] = SquaredErrorLSRT(sortedResponse,N);
            [crap, leftNodeError] = SquaredErrorLSRT(sortedResponse(1:i),N);
            [crap, rightNodeError] = SquaredErrorLSRT(sortedResponse((i+1):N),N);
            deltaError = parentNodeError - leftNodeError - rightNodeError;

            % Delta error ist null
            if deltaError < 0 % für Vermeidung von Rundungsfehlern,
                deltaError = 0;
            end

            % neuer besserer Split gefunden
            if ((deltaError >= deltaErrorBest) && ~isnan(deltaError))
                splitPoint = i;
                deltaErrorBest = deltaError;
                dimension = k;
                if dimension > 1
                   test = 0; 
                   
                end
            end
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
        alpha = alpha(dimension,:);
        dataLeftNode = orderForDataset(1:splitPoint,dimension);
        dataRightNode = orderForDataset((splitPoint+1):end,dimension);
        threshold = sortedPredictors(splitPoint,dimension)+(sortedPredictors(splitPoint+1,dimension)...
            -sortedPredictors(splitPoint,dimension))/2;    
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

