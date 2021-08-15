function [MAE, RMSE, predictions] = determineErrorGOMT(model, predictors, response)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
MAE = 0;
RMSE = 0;
N = size(predictors,1);
predictions = zeros(N,1);
for i=1:N
    predictions(i) = predictSampleGOMT(model, predictors(i,:));
    
    if isnan(predictions(i))
        warning('Prediction value is NaN');
    end
end

RMSE = sqrt(mean((response - predictions).^2));
MAE = mean(abs(response - predictions));
end

