% author: Marvin Schöne
% date: 09.08.2021
% refs: "Neural Networks and the Bias/Variance Dilemma" from Geman,
% Bienenstock and Doursat

clear;
clc;

% add path
addpath('01_workspace');
addpath('10_General_Functions');
RecursiveAddPath('11_GOMT');
RecursiveAddPath('12_GUIDE');
RecursiveAddPath('13_LSRT');

load('benchmarking_syntheticData__runs150_seedData3_seedBM3_starttime1629Uhr872021_finalBM_GOMTrOPG_GOMTphd_LSRT_CART.mat');
modelGOMT.benchmarking = benchmarking(3).dataset;
modelLSRT.benchmarking = benchmarking(6).dataset;

load('benchmarking_syntheticData__runs150_seedData3_seedBM3_starttime1650Uhr872021_finalBM_GUIDE.mat');
modelGUIDE.benchmarking = benchmarking(1).dataset;

for i=1:18
    modelGOMT.MSE = 0;   
    modelLSRT.MSE = 0;
    modelGUIDE.MSE = 0;
    
    %% calculate MSE and mean estimation on training data
    for j=1:150
        dataTest = data(i).run(j).test;
        ModeX = [1:size(dataTest,2)-1];
        
        
        % GOMT
        [MAE, RMSE, predictions] = determineErrorGOMT(modelGOMT.benchmarking(i).run(j).model, dataTest(:,1:end-1), dataTest(:,end));
        modelGOMT.MSE = modelGOMT.MSE + (RMSE^2)/150;
        
        % LSRT
        [error, y] = determineSquaredTestErrorLSRT(modelLSRT.benchmarking(i).run(j).model, [dataTest(:,end), dataTest(:,1:end-1)], ModeX);
        modelLSRT.MSE = modelLSRT.MSE + error/150; 
        
        % GUIDE
        [error, y] = determineSquaredTestErrorGUIDE(modelGUIDE.benchmarking(i).run(j).model, [dataTest(:,end), dataTest(:,1:end-1)], ModeX);
        modelGUIDE.MSE = modelGUIDE.MSE + error/150; 
        
        
        %% calculate bias and variance
        modelGOMT.bias(j) = 0;
        modelGOMT.variance(j) = 0;
        modelLSRT.bias(j) = 0;
        modelLSRT.variance(j) = 0;
        modelGUIDE.bias(j) = 0;
        modelGUIDE.variance(j) = 0;
        
        for k=1:size(dataTest,2)
            %% calculate mean estimation
            modelGOMT.meanEstimation = 0;
            modelLSRT.meanEstimation = 0;
            modelGUIDE.meanEstimation = 0;
            
            for l=1:150             
                y_Gomt(l) = predictSampleGOMT(modelGOMT.benchmarking(i).run(l).model,dataTest(k,1:end-1));
                y_Lsrt(l) = PredictSampleLSRT(modelLSRT.benchmarking(i).run(l).model,dataTest(k,1:end-1),ModeX);
                y_Guide(l) = PredictSampleGUIDE(modelGUIDE.benchmarking(i).run(l).model,dataTest(k,1:end-1),ModeX);

            end
            
            modelGOMT.bias(j) = modelGOMT.bias(j) + ((mean(y_Gomt) - dataTest(k,end))^2)/size(dataTest,2);
            modelGOMT.variance(j) = modelGOMT.variance(j) + mean((y_Gomt-mean(y_Gomt)).^2)/size(dataTest,2);
            
            modelLSRT.bias(j) = modelLSRT.bias(j) + ((mean(y_Lsrt) - dataTest(k,end))^2)/size(dataTest,2);
            modelLSRT.variance(j) = modelLSRT.variance(j) + mean((y_Lsrt-mean(y_Lsrt)).^2)/size(dataTest,2);
            
            modelGUIDE.bias(j) = modelGUIDE.bias(j) + ((mean(y_Guide) - dataTest(k,end))^2)/size(dataTest,2);
            modelGUIDE.variance(j) = modelGUIDE.variance(j) + mean((y_Guide-mean(y_Guide)).^2)/size(dataTest,2);
            
        end
    end
    
    modelGOMT.sumBias(i) = mean(modelGOMT.bias);
    modelGOMT.sumVariance(i) = mean(modelGOMT.variance);
    
    modelLSRT.sumBias(i) = mean(modelLSRT.bias);
    modelLSRT.sumVariance(i) = mean(modelLSRT.variance);
    
    modelGUIDE.sumBias(i) = mean(modelGUIDE.bias);
    modelGUIDE.sumVariance(i) = mean(modelGUIDE.variance);
    
    ratio(i).biasGUIDE = modelGUIDE.sumBias(i)/modelGOMT.sumBias(i);
    ratio(i).varianceGUIDE = modelGUIDE.sumVariance(i)/modelGOMT.sumVariance(i);
    
    ratio(i).biasLSRT = modelLSRT.sumBias(i)/modelGOMT.sumBias(i);
    ratio(i).varianceLSRT = modelLSRT.sumVariance(i)/modelGOMT.sumVariance(i);
    
    % report
    fprintf('\n------------------------------------------------------------ \n');
    fprintf('Report:  Iteration %i with data set %s \n',i, data(i).function);
    fprintf('GOMT: MSE: %f;   (squared) Bias: %f;   Variance: %f \n',round(modelGOMT.MSE,3),round(modelGOMT.sumBias(i),3),round(modelGOMT.sumVariance(i),3))
    fprintf('GUIDE: MSE: %f;   (squared) Bias: %f;   Variance: %f \n',round(modelGUIDE.MSE,3),round(modelGUIDE.sumBias(i),3),round(modelGUIDE.sumVariance(i),3))
    fprintf('LSRT: MSE: %f;   (squared) Bias: %f;   Variance: %f \n\n',round(modelLSRT.MSE,3),round(modelLSRT.sumBias(i),3),round(modelLSRT.sumVariance(i),3))
    
    % report ratio in percentage
    fprintf('Ratio GUIDE/GOMT: (squared) Bias: %i %%; Variance: %i %% \n',round((ratio(i).biasGUIDE-1)*100),round((ratio(i).varianceGUIDE-1)*100))
    fprintf('Ratio LSRT/GOMT: (squared) Bias: %i %%; Variance: %i %% \n',round((ratio(i).biasLSRT-1)*100),round((ratio(i).varianceLSRT-1)*100))
end