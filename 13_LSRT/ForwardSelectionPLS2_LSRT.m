function [coefficients,coefficientsNormalized,HK,dimensionZ] = ForwardSelectionPLS2_LSRT(response,predictors,criteria,eta)
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

coefficients = zeros(1,M+1);
coefficientsNormalized = zeros(1,M);
HK = [];


if eta > M
    eta = M;
end
maxDelta = 1;
for k=1:M
    i = 0;
    % determine value of criteria
    if criteria == "BIC" || criteria == "bic"
        valueCriteria = N*log(sum(Y.^2)/N);
    elseif criteria == "AIC" || criteria == "aic"
        valueCriteria = N*log(sum(Y.^2)/N) + 2*(i) + (2*i(i+1))/N-i-1;
    else
        error('criteria is not available');
    end
    i = 1;
    wMax = [];
    selections = zeros(1,M);
    remaining = [1:M];
    while i <= eta && maxDelta > 0
        maxDelta = 0;
        for i2=1:M
            if remaining(i2) > 0
                % determine hessian matrix
                logMask = selections > 0|[1:M] == remaining(i2);
                H = X(:,logMask)'*X(:,logMask);
                % Check whether the Matrix is singular
                if min(eig(H)) > 0.0001
                    % determine PLS-components
                    w = X(:,logMask)'*Y;
                    z = X(:,logMask)*w;
                    q = (Y'*z)/(z'*z);
                    p = (X(:,logMask)'*z)/(z'*z);
                    % pls-algorithm with ls-procedure
%                     w = inv(H)*X(:,logMask)'*Y;
%                     z = X(:,logMask)*w;
%                     q = 1;
%                     p = (X(:,logMask)'*z)/(z'*z);
                    % determine value of criteria
                    if criteria == "BIC" || criteria == "bic"
                        valueCriteriaNew = N*log(sum((Y - z*q).^2)/N) + log(N)*i;
                    elseif criteria == "AIC" || criteria == "aic"
                        valueCriteriaNew = N*log(sum((Y - z*q).^2)/N) + 2*(i) + (2*i*(i+1))/N-i-1;
                    else
                        error('criteria is not available');
                    end

                    % detect best greedy-selection
                    if (valueCriteria-valueCriteriaNew) > maxDelta
                        maxDelta = (valueCriteria-valueCriteriaNew);           
                        Index = i2;
                        logMaskMax = logMask;
                        wMax = w;
                        zMax = z;
                        qMax = q;
                        pMax = p;
                    end
                else
                    remaining(i2) = -1;
                end
            end
        end

        if maxDelta > 0
            if k > 1
                test = 0;
            end    
            selections(Index) = 1;
            remaining(Index) = -1;
            valueCriteria = valueCriteria - maxDelta;
            i = i+1;
        end
    end

    if isempty(wMax)
        if k == 1
            dimensionZ = k;
            HK = predictors;
            coefficientsNormalized = eye(M);
            coefficients = zeros(1,M);
            coefficients = [meanY-sqrt(preVarY).*coefficients./sqrt(preVarX)*meanX' (coefficients./sqrt(preVarX).*sqrt(preVarY))];
            dimensionZ = M;
        end
        break;
    else
        coefficients(k,[false logMaskMax]) = (wMax'*qMax*sqrt(preVarY))./sqrt(preVarX(logMaskMax));
        coefficients(k,1) = meanY - sqrt(preVarY)*qMax*sum((wMax'.*meanX(logMaskMax))./sqrt(preVarX(logMaskMax)));
        coefficientsNormalized(k,logMaskMax) =  wMax'./sqrt(preVarX(logMaskMax));
        HK(:,k) = (zMax+sum((wMax'.*meanX(logMaskMax))./sqrt(preVarX(logMaskMax))))/norm(coefficientsNormalized(k,:));
        coefficientsNormalized(k,:) = coefficientsNormalized(k,:)/norm(coefficientsNormalized(k,:));
        [~,index] = max(abs(coefficientsNormalized));
        if coefficientsNormalized(k,index) < 0
            HK(:,k) = HK(:,k)*(-1);
            coefficientsNormalized(k,:) = coefficientsNormalized(k,:)*(-1);
        end
        dimensionZ = k;
        maxDelta = 1;
        %reduction for the next component
        pXfit = zeros(M,1);
        pXfit(logMaskMax) = pMax;
        X = X - zMax*pXfit';
        varY = var(Y);
        Y = Y - zMax*qMax;
        if varY-var(Y) < 0.01 || (1-var(Y)) > 0.9
            break;
        end
    end
end
    
end

