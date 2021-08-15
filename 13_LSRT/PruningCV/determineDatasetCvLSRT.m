function [TestCV, TrainCV, dimCV_new] = determineDatasetCvLSRT(dimCV, train)
%DETERMINEDATASATCV Summary of this function goes here
%   Detailed explanation goes here
sizeDataset = size(train,1);
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
    TestCV{1,i+1} = train(dataIndex(lowerBound:upperBound),:);
end
TestCV{1,i+2} = train(dataIndex((upperBound+1):end),:);

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

dimCV_new = dimCV;

