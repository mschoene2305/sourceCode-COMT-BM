function [index,errorAlpha] = complexityEstimationCV(dataTrain,alphaValues,options)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
sizeDataset = size(dataTrain,1);
dimCV = 10;
flag = 0;

if options.report
    flag = 1;
    options.report = 0;
end

if dimCV > sizeDataset
    dimCV = sizeDataset;
end
sizeCV = sizeDataset/dimCV;
dataIndex = randperm(sizeDataset);

exit = 0;
%% Dynamische Anpassung der zu erzeugenden Datensätze, wenn diese sehr ungleich aufgeteilt werden würden
while exit == 0
    if round(sizeCV)/sizeCV > 1.06
        dimCV = dimCV-1;
        sizeCV = sizeDataset/dimCV;

    elseif round(sizeCV)/sizeCV < 0.95
        dimCV = dimCV+1;
        sizeCV = sizeDataset/dimCV;

    else
        exit = 1;

    end
end
sizeCV = round(sizeCV);

%% Erzeugung von dimCV Einzeldatensätzen (Testdatensätze)
TestCV = cell(1,dimCV);
for i=0:dimCV-2
    lowerBound = i*sizeCV +1;
    upperBound = (i+1)*sizeCV;
    if upperBound > sizeDataset
        upperBound = sizeDataset;
    end
    TestCV{1,i+1} = dataTrain(dataIndex(lowerBound:upperBound),:);
end
TestCV{1,i+2} = dataTrain(dataIndex((upperBound+1):end),:);

%% Erzeugung der Trainingsdatensätze
TrainCV = cell(1,dimCV);
for i=1:dimCV
    buffer = [];
    for i2=1:dimCV
        if i2~=i
            buffer = [buffer; TestCV{1,i2}];
        end
    end
    TrainCV{1,i} = buffer;
end

%% Estimate aplha values to prune determined models by fixed alpha-value
alphaCV = zeros(1,(size(alphaValues,2)));
alphaCV(1) = 0;
for i=2:size(alphaCV,2)-1
    if alphaValues(i) > 0 && alphaValues(i+1) > 0
        alphaCV(i) = real(sqrt(alphaValues(i)*alphaValues(i+1)));
    else
        alphaCV(i) = 0;
    end
end
alphaCV(end) = alphaValues(end) + (alphaValues(end)-alphaCV(end-1));

%% Estimate models by cross validation data sets and prune them to to different complexities (depending on alphaCV)
CVSubmodels = cell(1,dimCV);
for i=1:dimCV
    dataTrainCV = TrainCV{i};
    CVmodel = trainGOMT(dataTrainCV(:,1:end-1),dataTrainCV(:,end),options);
    CVSubmodels{1,i} = pruningFixedAlphaGOMT(CVmodel, alphaCV);
end

residualsCombined = zeros(size(alphaCV,2),1);
for i=1:size(alphaCV,2)
    RMSE = zeros(1,dimCV);
    residualsBuffer = [];
    predictionsBuffer = [];
    
    for i2=1:dimCV
        Submodels = CVSubmodels{1,i2};
        currentModel = Submodels{1,i};
        dataTest = TestCV{1,i2};
        [~, RMSE(i2), predictions] = determineErrorGOMT(currentModel, dataTest(:,1:end-1), dataTest(:,end));
        residualsBuffer = [residualsBuffer; (dataTest(:,end)-predictions)];
        predictionsBuffer = [predictionsBuffer; predictions];
    end
    
    residualsCombined(i,1:size(residualsBuffer,1)) = residualsBuffer';
    predictionsCombined(i,1:size(predictionsBuffer,1)) = predictionsBuffer';
    errorAlpha(i) = mean(RMSE.^2); 
    OneSE(i) = sqrt(var(RMSE.^2)/sizeDataset);
    OneSE(i) = sqrt(var(residualsCombined(i,:).^2)/sizeDataset);
end

[MSE, index] = min(errorAlpha);

%% X-SE-Rule
% determine 1SE values by Breimans`equation on p. 307 of "Classification
% And Regression Trees"
factor = 0.5;

if flag
    fprintf('Report: Standard error estimation: %f\n', round(OneSE(index),4))
end

mask = [1:size(errorAlpha,2)];
mask = mask(errorAlpha<=(MSE+(factor*OneSE(index))));
index = mask(end);
MSE = errorAlpha(index);

end

