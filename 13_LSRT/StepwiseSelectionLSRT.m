function [coefficients,coefficientsNormalized,z,dimensionZ] = StepwiseSelectionLSRT(response,predictors,criteria)
%STEPWISESELECTION Summary of this function goes here
%   Detailed explanation goes here
[N M] = size(predictors);
% add ones  to the Predicotrs
preVarX = var(predictors);
preVarY = var(response);
meanX = mean(predictors);
meanY = mean(response);
X = (predictors - meanX)./sqrt(preVarX);
Y = (response - meanY)/sqrt(preVarY);
selections = zeros(1,M);
remaining = [1:M];
coefficients = zeros(1,M);
coefficientsNormalized = zeros(1,M);
maxDelta = 1;
i=0;

if criteria == "BIC" || criteria == "bic"
    valueCriteria = N*log(sum(Y.^2)/N);
    invertation = 1;
elseif criteria == "AIC" || criteria == "aic"
    valueCriteria = N*log(sum(Y.^2)/N) + 2*(i) + (2*i(i+1))/N-i-1;
    invertation = 1;
elseif criteria == "R2" || criteria == "r2"
    valueCriteria = 1-(N-1)/(N-i-1);
    invertation = -1;
elseif criteria == "R2+" || criteria == "r2+"
    valueCriteria = 1-(N-1)/(N-i-1);
    invertation = -1;
else
    error('criteria is not available');
end

Y_rest = Y;
while i < M && maxDelta > 0 && max(remaining) > (-1)
    i=i+1;
    maxDelta = 0;
    coefficientsTemp = zeros(1,1);
    
    %% Forward Selection
    for i2=1:M
        if remaining(i2) > 0
            % determine hessian matrix
            H = X(:,selections > 0|[1:M] == remaining(i2))'*X(:,selections > 0|[1:M] == remaining(i2));
            % Check whether the Matrix is singular
            if min(eig(H)) > 0.0001
                % determine LS-coefficients
                H = X(:,remaining(i2))'*X(:,remaining(i2));
                coefficientsTemp = inv(H)*X(:,remaining(i2))'*Y_rest;
                % determine value of criteria
                if criteria == "BIC" || criteria == "bic"
                    Y_restNew = Y_rest - X(:,remaining(i2))*coefficientsTemp';
                    valueCriteriaNew = N*log(sum((Y_restNew).^2)/N) + log(N)*i;
                elseif criteria == "AIC" || criteria == "aic"
                    Y_restNew = Y_rest - X(:,remaining(i2))*coefficientsTemp';
                    valueCriteriaNew = N*log(sum((Y_restNew).^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                elseif criteria == "R2" || criteria == "r2"
                    valueCriteriaNew = 1-((X(:,logMask)*coefficientsTemp(logMask)'-meanY)'*(X(:,logMask)*coefficientsTemp(logMask)'-meanY))...
                        /((Y-meanY)'*(Y-meanY));
                elseif criteria == "R2+" || criteria == "r2+"
                    valueCriteriaNew = 1-(1-((X(:,logMask)*coefficientsTemp(logMask)'-meanY)'...
                        *(X(:,logMask)*coefficientsTemp(logMask)'-meanY))/((Y-meanY)'*(Y-meanY)))*((N-1)/(N-i-1));
                else
                    error('criteria is not available');
                end
                
                % detect best greedy-selection
                if (valueCriteria-valueCriteriaNew)*invertation > maxDelta
                    maxDelta = (valueCriteria-valueCriteriaNew)*invertation;           
                    Index = i2;
                    Y_restBest = Y_restNew;
                    valueCriteriaBest = valueCriteriaNew;
                    %coefficients(logMask) = coefficientsTemp(logMask);
                    %coefficients(~logMask) = 0;
                end
                    
            else
                remaining(i2) = -1;
            end
        end
    end
    
    if maxDelta > 0
        selections(Index) = 1;
        remaining(Index) = -1;
        valueCriteria = valueCriteriaBest;
        Y_rest = Y_restBest;
    end
    
    %% Backward Selection
    if i > M && maxDelta == 0 % only activated if at the pevious step a variable is added and there are is more than one predictor included
        exit = false;
        coefficients(1,selections > 0) = inv(X(:,selections > 0)'*X(:,selections > 0))*X(:,selections > 0)'*Y;
        if criteria == "BIC" || criteria == "bic"
            valueCriteria = N*log(sum((Y - X(:,selections > 0)*coefficients(1,selections > 0)').^2)/N) + log(N)*i;
        elseif criteria == "AIC" || criteria == "aic"
            valueCriteria = N*log(sum((Y - X(:,selections > 0)*coefficients(1,selections > 0)').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
%            elseif criteria == "R2" || criteria == "r2"
%                valueCriteriaNew = 1-((X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY)'*(X(:,logMaskBackward)...
%                    *coefficientsTemp(logMaskBackward)'-meanY))/((Y-meanY)'*(Y-meanY));
%            elseif criteria == "R2+" || criteria == "r2+"
%                valueCriteriaNew = 1-(1-((X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY)'...
%                    *(X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY))/((Y-meanY)'*(Y-meanY)))*((N-1)/(N-i-1));
        else
            error('criteria is not fully available');
        end
        while i > 1 && exit == false
            maxDelta = 0;
            coefficientsTemp = zeros(1,M);
            maxDeltaBackward = 0;
            selectionsBackward = [1:M];
            selectionsBackward = selectionsBackward(selections > 0);
            sizeSelections = size(selectionsBackward,2);
            for i2=1:sizeSelections
                if Index ~= selectionsBackward(i2);
                    logMaskBackward = selections > 0;
                    logMaskBackward(selectionsBackward(i2)) = false;
                    % determine hessian matrix
                    H = X(:,logMaskBackward)'*X(:,logMaskBackward);
                    % determine LS-coefficients
                    coefficientsTemp(logMaskBackward) = inv(H)*X(:,logMaskBackward)'*Y;
                    % determine value of criteria
                    if criteria == "BIC" || criteria == "bic"
                        valueCriteriaNew = N*log(sum((Y - X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)').^2)/N) + log(N)*i;
                    elseif criteria == "AIC" || criteria == "aic"
                        valueCriteriaNew = N*log(sum((Y - X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                    elseif criteria == "R2" || criteria == "r2"
                        valueCriteriaNew = 1-((X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY)'*(X(:,logMaskBackward)...
                            *coefficientsTemp(logMaskBackward)'-meanY))/((Y-meanY)'*(Y-meanY));
                    elseif criteria == "R2+" || criteria == "r2+"
                        valueCriteriaNew = 1-(1-((X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY)'...
                            *(X(:,logMaskBackward)*coefficientsTemp(logMaskBackward)'-meanY))/((Y-meanY)'*(Y-meanY)))*((N-1)/(N-i-1));
                    else
                        error('criteria is not available');
                    end

                    % detect best greedy-selection
                    if (valueCriteria-valueCriteriaNew)*invertation > maxDelta
                        maxDelta = (valueCriteria-valueCriteriaNew)*invertation;           
                        IndexBackward = i2;
                        coefficients(logMaskBackward) = coefficientsTemp(logMaskBackward);
                        coefficients(~logMaskBackward) = 0;
                    end
                end
            end

            if maxDelta > 0
                i=i-1;
                selections(IndexBackward) = 0;
                valueCriteria = valueCriteria - (maxDelta*invertation);
            else
                exit = true;
            end
        end
    end
end

% use univariate splits
if maxDelta == 0 && i<=2
    z = predictors;
    coefficientsNormalized = eye(M);
    coefficients = [meanY-sqrt(preVarY).*coefficients./sqrt(preVarX)*meanX' (coefficients./sqrt(preVarX).*sqrt(preVarY))];
    dimensionZ = M;
% use multivariate splits 
else     
    coefficients(1,selections > 0) = inv(X(:,selections > 0)'*X(:,selections > 0))*X(:,selections > 0)'*Y;
    coefficientsNormalized = coefficients./sqrt(preVarX);
    z = (X*coefficients' + coefficientsNormalized*meanX')/norm(coefficientsNormalized);
    coefficients = [meanY-sqrt(preVarY).*coefficientsNormalized*meanX' (coefficientsNormalized.*sqrt(preVarY))];
    coefficientsNormalized = coefficientsNormalized/norm(coefficientsNormalized);
    [~,index] = max(abs(coefficientsNormalized));
    if coefficientsNormalized(index) < 0
        z = z*(-1);
        coefficientsNormalized = coefficientsNormalized*(-1);
    end
    
    dimensionZ = 1;
end

end

