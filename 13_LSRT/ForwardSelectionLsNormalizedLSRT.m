function [coefficients,coefficientsNormalized,z,dimensionZ] = ForwardSelectionLsNormalizedLSRT(response,predictors,criteria,eta)
%UNTITLED Summary of this function goes here
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

if eta > M
    eta = M;
end

while i < eta && maxDelta > 0
    i=i+1;
    maxDelta = 0;
    coefficientsTemp = zeros(1,M);
    for i2=1:M
        if remaining(i2) > 0
            logMask = selections > 0|[1:M] == remaining(i2);
            % determine hessian matrix
            H = X(:,logMask)'*X(:,logMask);
            % Check whether the Matrix is singular
            if min(eig(H)) > 0.0001
                % determine LS-coefficients
                coefficientsTemp(logMask) = H\X(:,logMask)'*Y;
                % determine value of criteria
                if criteria == "BIC" || criteria == "bic"
                    valueCriteriaNew = N*log(sum((Y - X(:,logMask)*coefficientsTemp(logMask)').^2)/N) + log(N)*i;
                elseif criteria == "AIC" || criteria == "aic"
                    valueCriteriaNew = N*log(sum((Y - X(:,logMask)*coefficientsTemp(logMask)').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
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
                    coefficients(logMask) = coefficientsTemp(logMask);
                    coefficients(~logMask) = 0;
                end
                    
            else
                remaining(i2) = -1;
            end
        end
    end
    
    if maxDelta > 0
        selections(Index) = 1;
        remaining(Index) = -1;
        valueCriteria = valueCriteria - (maxDelta*invertation);
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

% plotOption =0;
% if plotOption == 1
%     figure()
%     if size(z,2) == 1
%         scatter(z, Y)
%     end
%     H = X'*X;
%     b = H*X'*Y;    
%     X_new = ((Y-X*b)./N).*X;
%     [V, D] = eig(X_new'*X);
%     [~,index] = max(abs(D*ones(size(D,2),1)));
%     figure()
%     scatter(X*V(:,index), Y)
%     xlabel('1st PHD');
%     ylabel('y');

end

