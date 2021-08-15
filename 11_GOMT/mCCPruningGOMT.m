function [Model, Submodels] = mCCPruningGOMT(Model,options)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%% construct subtrees out of "Model" by Breimans weakest link cutting
Submodels = weakestLinkCutting(Model);

%% select subtree with a suitable complexity using crossvalidation
[index,errorAlpha] = complexityEstimationCV([Model(1).predictor, Model(1).response],cell2mat(Submodels(2,:)),options);
Model = Submodels{1,index};

%% plot prunign results (graph with tree size and test error)
if options.report && options.pruning == "post" 
    sizeSubtrees = zeros(1,size(Submodels,2)-1);
    for i=1:size(Submodels,2)
        sizeSubtrees(i) = size(Submodels{1,i},2);
    end
    figure()
    plot(sizeSubtrees,errorAlpha);
    hold on
    scatter(sizeSubtrees(index),errorAlpha(index));
    title('Post Pruning: Error-Graph for different model complexities');
    ylabel('RMSE resulting from Cross Validation');
    xlabel('model complexity measured by number of notes');
end

end

