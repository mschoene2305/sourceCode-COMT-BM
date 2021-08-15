%% add paths
addpath('10_General_Functions')
addpath('12_GUIDE')

%% set random seed and select number of workers
rng('default')
seedBenchmarking = 3;
rng(seedBenchmarking)
workers = 12;

%% start bechnmarking on synthetic data
clear benchmarking
clear run
c = clock;
starttime = string(c(4)) + string(c(5)) + "Uhr" + string(c(3)) + string(c(2)) + string(c(1));
infoWorkspace ="_runs" + string(runs) + "_seedData" + string(seedData) +...
    "_seedBM" + string(seedBenchmarking) + "_starttime" + starttime;
filename = "benchmarking_syntheticData_" + infoWorkspace + addInfo

%% start benchmarking for either synthetic or real data
for i=1:size(data,2)
data(i).function
k=1;

    %% GUIDE
    parfor (j=1:size(data(i).run,2),workers)
    %for j=1:size(data(i).run,2)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        ModeX = [1:size(dataTrain,2)-1];
        [GuideTree, crap] = trainGuideTree(dataTrain,mod(j,9)+1,true,true,"GUIDE");
        [ErrorSumGUIDE, predictions] = determineSquaredTestErrorGUIDE(GuideTree, [dataTest(:,end), dataTest(:,1:end-1)], ModeX);
        run(j).RMSE = sqrt(ErrorSumGUIDE);
        run(j).Predictions = predictions;
        run(j).model = GuideTree;
        run(j).sizeModel = size(GuideTree,1);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GUIDE";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report GUIDE:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

%% save data after each iteration
save(filename,'data','benchmarking','seedData','seedBenchmarking');

end