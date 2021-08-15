function [coefficients,coefficientsNormalized,z,dimensionZ] = PrincipalHesseDirectionsLSRT(response,predictors)
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

% extract first phd
H = X'*X;
b = H*X'*Y;    
X_new = ((Y-X*b)./N).*X;
[V, D] = eig(X_new'*X);
[~,index] = max(abs(D*ones(size(D,2),1)));
coefficients = V(:,index)';

% resubstituate mean an variance
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


    

