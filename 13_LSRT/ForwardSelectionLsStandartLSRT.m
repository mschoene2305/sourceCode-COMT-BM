function [coefficients,coefficientsNormalized,z,dimensionZ] = ForwardSelectionLsStandartLSRT(response,predictors,criteria,eta)
%UNTITLED Summarresponse of this function goes here
%   Detailed explanation goes here
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[N M] = size(predictors);
predictors = [ones(N,1) predictors];
selections = zeros(1,M);
remaining = [1:M];
coefficients = zeros(1,M+1);
coefficientsNormalized = zeros(1,M);
maxDelta = 1;
i=0;

if criteria == "BIC" || criteria == "bic"
    valueCriteria = N*log(sum(response.^2)/N);
    invertation = 1;
elseif criteria == "AIC" || criteria == "aic"
    valueCriteria = N*log(sum(response.^2)/N) + 2*(i) + (2*i(i+1))/N-i-1;
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
    coefficientsTemp = zeros(1,M+1);
    for i2=1:M
        if remaining(i2) > 0
            logMask = selections > 0|[1:M] == remaining(i2);
            % determine hessian matrix
            H = predictors(:,[true logMask])'*predictors(:,[true logMask]);
            % Check whether the Matrix is singular
            if min(eig(H)) > 0.0001
                % determine LS-coefficients
                coefficientsTemp([true logMask]) = H\predictors(:,[true logMask])'*response;
                % determine value of criteria
                if criteria == "BIC" || criteria == "bic"
                    valueCriteriaNew = N*log(sum((response - predictors(:,[true logMask])*coefficientsTemp([true logMask])').^2)/N) + log(N)*i;
                elseif criteria == "AIC" || criteria == "aic"
                    valueCriteriaNew = N*log(sum((response - predictors(:,[true logMask])*coefficientsTemp([true logMask])').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                else
                    error('criteria is not available');
                end
                
                % detect best greedy-selection
                if (valueCriteria-valueCriteriaNew)*invertation > maxDelta
                    maxDelta = (valueCriteria-valueCriteriaNew)*invertation;           
                    Index = i2;
                    coefficients([true logMask]) = coefficientsTemp([true logMask]);
                    coefficients(~[true logMask]) = 0;
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
    z = predictors(:,2:end);
    coefficientsNormalized = eye(M);
    dimensionZ = M;
% use multivariate splits 
else       
    coefficientsNormalized = coefficients(2:end);
    z = (predictors(:,2:end)*coefficientsNormalized')/norm(coefficientsNormalized);
    coefficientsNormalized = coefficientsNormalized/norm(coefficientsNormalized);
    [~,index] = max(abs(coefficientsNormalized));
    if coefficientsNormalized(index) < 0
        z = z*(-1);
        coefficientsNormalized = coefficientsNormalized*(-1);
    end
    
    dimensionZ = 1;
end


end
