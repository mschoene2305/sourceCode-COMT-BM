%% add paths
addpath('10_General_Functions')
addpath('14_M5PrimeLab')

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

    %% M5
    parfor (j=1:size(data(i).run,2),workers)
    %for j=1:size(data(i).run,2)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        % trainParams = m5pparams(1, 2, 4, 1, 0, 0.05, 0, Inf, 0);
        [model, time, ensembleResults] = m5pbuild(dataTrain(:,1:end-1), dataTrain(:,end));
        results = m5ptest(model, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = results.RMSE;
        run(j).model = model;
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).model = "M5";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report M5:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

%% save data after each iteration
save(filename,'data','benchmarking','seedData','seedBenchmarking');

end