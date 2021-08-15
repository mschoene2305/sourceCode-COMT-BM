function [firstPHD, residuals] = PHD(X, y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% calculate data properties
[n m] = size(X);

%% standardize data
varX = var(X); varY = var(y);
meanX = mean(X); meanY = mean(y);
sdX = (X - meanX)./sqrt(varX); sdY = (y - meanY)/sqrt(varY);

%% construct local model
beta = (sdX'*sdX)\sdX'*sdY;
residuals = sdY - sdX*beta;

%% determine principal hessian directions
X_phd = ((residuals./n).*sdX)'*sdX;
[phd, eigenv] = eig(X_phd);
[~,first] = max(abs(eigenv*ones(size(eigenv,2),1)));

firstPHD = diag(varX.^(-1/2))*phd(:,first);
end

