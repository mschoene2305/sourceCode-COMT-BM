function [error, y] = determineSquaredTestErrorGUIDE(Tree, Dataset, ModeX)
%DETERMINESQUAREDTESTERROR Summary of this function goes here
%   Detailed explanation goes here
error = 0;
sizeDataset = size(Dataset,1);
y = zeros(sizeDataset,1);
for i=1:sizeDataset
    y(i) = PredictSampleGUIDE(Tree, Dataset(i,2:end), ModeX);
    error = error + ((Dataset(i,1) - y(i))^2)/sizeDataset;  
end
end

