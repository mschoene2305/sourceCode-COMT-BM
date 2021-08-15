function [coefficients,coefficientsNormalized,z,NoteTerminal] = ForwardSelectionLS(response,predictors,criteria,eta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
[N M] = size(predictors);
% add ones  to the Predicotrs
predictors = [ones(N,1) predictors];
selections = [1 zeros(1,M)];
remaining = [1:M];
coefficients = zeros(1,M+1);
coefficientsNormalized = zeros(1,M);
z = 0;
NoteTerminal = 0;

i=0;
% determine hessian matrix
H = predictors(:,selections > 0)'*predictors(:,selections > 0);
% determine LS-coefficients
coefficients(selections > 0) = inv(H)*predictors(:,selections > 0)'*response;
% determine value of criteria
if criteria == "BIC" || criteria == "bic"
    valueCriteria = N*log(sum((response - predictors(:,selections > 0)*coefficients(:,selections > 0)').^2)/N) + log(N)*i;
elseif criteria == "AIC" || criteria == "aic"
    valueCriteria = N*log(sum((response - predictors(:,selections > 0)*coefficients(:,selections > 0)').^2)/N) + 2;
else
    error('criteria is not available');
end

i = i+1;
if eta > M
    eta = M;
end
maxDelta = 1;

while i <= eta && maxDelta > 0
    maxDelta = 0;
    coefficientsTemp = zeros(1,M+1);
    for i2=1:M
        if remaining(i2) > 0
            logMask = selections > 0|[0:M] == remaining(i2);
            % determine hessian matrix
            H = predictors(:,logMask)'*predictors(:,logMask);
            % Check whether the Matrix is singular
            if min(eig(H)) > 0.0001
                % determine LS-coefficients
                coefficientsTemp(logMask) = inv(H)*predictors(:,logMask)'*response;
                % determine value of criteria
                if criteria == "BIC" || criteria == "bic"
                    valueCriteriaNew = N*log(sum((response - predictors(:,logMask)*coefficientsTemp(logMask)').^2)/N) + log(N)*i;
                elseif criteria == "AIC" || criteria == "aic"
                    valueCriteriaNew = N*log(sum((response - predictors(:,logMask)*coefficientsTemp(logMask)').^2)/N) + 2*(i+1);
                else
                    error('criteria is not available');
                end
                
                % detect best greedy-selection
                if (valueCriteria-valueCriteriaNew) > maxDelta
                    maxDelta = (valueCriteria-valueCriteriaNew);           
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
        selections(Index+1) = 1;
        remaining(Index) = -1;
        valueCriteria = valueCriteria - maxDelta;
        i = i+1;
    end
end

vectorLength = norm(coefficients(2:end));

if vectorLength == 0
    NoteTerminal = 1;
else
    z = (response - coefficients(1))/vectorLength;
    coefficientsNormalized = coefficients(2:end)/vectorLength;
    [~,index] = max(abs(coefficientsNormalized));
    if coefficientsNormalized < 0
        z = z*(-1);
        coefficientsNormalized = coefficientsNormalized*(-1);
    end
end

end

