function [beta] = firstCompPLS(X,y)

% standardization
beta = zeros(size(X,2),1);
varX = var(X); varY = var(y);
mask = varX > 0;
meanX = mean(X); meanY = mean(y);
sdX = (X - meanX)./sqrt(varX); sdY = (y - meanY)/sqrt(varY);

% weights W are oriented according to the bigges covariance
W = sdX(:,mask)'*sdY; 
% normalization to unit vector
W = W/norm(W); 
% construct latent variables
T = sdX(:,mask) * W; 
% determine coefficients do describe X and y by latent variables
Q = (sdY'*T)/(T'*T);

beta(mask) = (W*(Q*sqrt(varY)))./sqrt(varX(mask))';
beta = [meanY - sum(beta.*meanX'); beta];

end

