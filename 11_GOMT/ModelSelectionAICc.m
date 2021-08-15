function [coefficients] = ModelSelectionAICc(response,predictors,fullModel)


[N, M] = size(predictors(:,2:end));

if isempty(fullModel) % determine full-order model
    H = predictors'*predictors;
    if (min(eig(H)) > 0.0001) && ((M-1) < N)
        coefficients = H\predictors'*response;
    
    elseif N == 1 || var(response) == 0
        coefficients = zeros(M+1,1);
        coefficients(1) = mean(response);
        
    else% forward-selection
        selections = zeros(1,M);
        remaining = [1:M];
        coefficients = zeros(1,M+1);
        valueCriteria = [];
        Index = [];
        maxDelta = 1;
        i=0;
        while ((maxDelta == 0 && i==1) || (maxDelta > 0)) && mean(remaining)>(-1)
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
                        valueCriteriaNew = N*log(sum((response - predictors(:,[true logMask])*coefficientsTemp([true logMask])').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                        % detect best greedy-selection
                        if isempty(valueCriteria)
                            valueCriteria = valueCriteriaNew;
                            maxDelta = 0;
                            Index = i2;
                            coefficients([true logMask]) = coefficientsTemp([true logMask]);
                            coefficients(~[true logMask]) = 0;
                        elseif ((valueCriteria-valueCriteriaNew) > maxDelta) 
                            maxDelta = (valueCriteria-valueCriteriaNew);           
                            Index = i2;
                            coefficients([true logMask]) = coefficientsTemp([true logMask]);
                            coefficients(~[true logMask]) = 0;
                        end

                    else
                        remaining(i2) = -1;
                    end
                end
            end

            if (((maxDelta == 0 && i==1) || (maxDelta > 0))) && (isempty(Index) == 0)
                selections(Index) = 1;
                remaining(Index) = -1;
                valueCriteria = valueCriteria - maxDelta;
            elseif isempty(Index)
                coefficients(1,1) = mean(response);

            end
        end
        coefficients = coefficients';
    end
    
elseif sum(fullModel(2:end,:) == 0) == 0 % backward-elimination and check, if model was already regularized by forward-selection
    selections = ones(1,M);
    remaining = [1:M];
    coefficients = zeros(1,M+1);
    valueCriteria = N*log(sum((response - predictors*fullModel).^2)/N) + 2*(M) + (2*(M)*(M+1))/(N-M-1);
    Index = [];
    maxDelta = 1;
    i=0;
    while ((maxDelta == 0 && i==1) || (maxDelta > 0)) && mean(remaining)>(-1)
        i=i+1;
        maxDelta = 0;
        coefficientsTemp = zeros(1,M+1);
        for i2=1:M
            if remaining(i2) > 0
                logMask = selections > 0&not([1:M] == remaining(i2));
                % determine hessian matrix
                H = predictors(:,[true logMask])'*predictors(:,[true logMask]);
                % Check whether the Matrix is singular
                if min(eig(H)) > 0.0001
                    % determine LS-coefficients
                    coefficientsTemp([true logMask]) = H\predictors(:,[true logMask])'*response;
                    % determine value of criteria
                    valueCriteriaNew = N*log(sum((response - predictors(:,[true logMask])*coefficientsTemp([true logMask])').^2)/N) + 2*(M-i) + (2*(M-i)*(M-i+1))/N-(M-i)-1;
                    % detect best greedy-selection
                    if ((valueCriteria-valueCriteriaNew) > maxDelta) 
                        maxDelta = (valueCriteria-valueCriteriaNew);           
                        Index = i2;
                        coefficients([true logMask]) = coefficientsTemp([true logMask]);
                        coefficients(~[true logMask]) = 0;
                    end

                else
                    remaining(i2) = -1;
                end
            end
        end

        if (((maxDelta == 0 && i==1) || (maxDelta > 0))) && (isempty(Index) == 0)
            selections(Index) = 0;
            remaining(Index) = -1;
            valueCriteria = valueCriteria - maxDelta;
        elseif isempty(Index)
            coefficients = fullModel';

        end
    end
    if isempty(coefficients)
        coefficients = zeros(M+1,1);
        coefficients(1) = mean(response);
    else
        coefficients = coefficients';
    end
    
elseif sum(abs(fullModel(1:end,:))) == 0 % construct LS model by forward selection
    selections = zeros(1,M);
    remaining = [1:M];
    coefficients = zeros(1,M+1);
    valueCriteria = [];
    Index = [];
    maxDelta = 1;
    i=0;
    while ((maxDelta == 0 && i==1) || (maxDelta > 0)) && mean(remaining)>(-1)
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
                    valueCriteriaNew = N*log(sum((response - predictors(:,[true logMask])*coefficientsTemp([true logMask])').^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                    % detect best greedy-selection
                    if isempty(valueCriteria)
                        valueCriteria = valueCriteriaNew;
                        maxDelta = 0;
                        Index = i2;
                        coefficients([true logMask]) = coefficientsTemp([true logMask]);
                        coefficients(~[true logMask]) = 0;
                    elseif ((valueCriteria-valueCriteriaNew) > maxDelta) 
                        maxDelta = (valueCriteria-valueCriteriaNew);           
                        Index = i2;
                        coefficients([true logMask]) = coefficientsTemp([true logMask]);
                        coefficients(~[true logMask]) = 0;
                    end

                else
                    remaining(i2) = -1;
                end
            end
        end

        if (((maxDelta == 0 && i==1) || (maxDelta > 0))) && (isempty(Index) == 0)
            selections(Index) = 1;
            remaining(Index) = -1;
            valueCriteria = valueCriteria - maxDelta;
        elseif isempty(Index)
            coefficients(1,1) = mean(response);

        end
    end
    coefficients = coefficients';

else % LS-model was also regularized by forward-selection
    coefficients = fullModel;
end

end

