

%% add paths
addpath('10_General_Functions')
RecursiveAddPath('11_GOMT');
RecursiveAddPath('13_LSRT');

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

    %% GOMT with LS+rOPG and local hinge search
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        Model_rOPG = GOMT(dataTrain(:,1:end-1),dataTrain(:,end),'splitdirection','rOPG','plot',0,'report',0,'localModels','full','splitpoint','HINGE_LOCAL','notesize',2*(size(dataTrain,2)-1)+1);
        [rOPG_MAE, rOPG_RMSE, rOPG_predictions] = determineErrorGOMT(Model_rOPG, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = rOPG_RMSE;
        run(j).Predictions = rOPG_predictions;
        run(j).model = Model_rOPG;
        run(j).sizeModel = size(Model_rOPG,2);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GOMT_rOPG_hingeLocal_fullLM";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report HF-GOMT with rOPG:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

    %% GOMT with LS+rOPG and global hinge search
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        Model_rOPG = GOMT(dataTrain(:,1:end-1),dataTrain(:,end),'splitdirection','rOPG','plot',0,'report',0,'localModels','full','splitpoint','HINGE_GLOBAL','notesize',2*(size(dataTrain,2)-1)+1);
        [rOPG_MAE, rOPG_RMSE, rOPG_predictions] = determineErrorGOMT(Model_rOPG, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = rOPG_RMSE;
        run(j).Predictions = rOPG_predictions;
        run(j).model = Model_rOPG;
        run(j).sizeModel = size(Model_rOPG,2);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GOMT_rOPG_hingeGlobal_fullLM";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report GHF-GOMT with rOPG:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

    %% GOMT with LS+rOPG and SUPPORT splitpoint-selection
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        Model_rOPG = GOMT(dataTrain(:,1:end-1),dataTrain(:,end),'splitdirection','rOPG','plot',0,'report',0,'localModels','full','splitpoint','SUPPORT','notesize',2*(size(dataTrain,2)-1)+1);
        [rOPG_MAE, rOPG_RMSE, rOPG_predictions] = determineErrorGOMT(Model_rOPG, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = rOPG_RMSE;
        run(j).Predictions = rOPG_predictions;
        run(j).model = Model_rOPG;
        run(j).sizeModel = size(Model_rOPG,2);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GOMT_rOPG_SUPPORT_fullLM";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report SUP-GOMT with rOPG:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

     %% GOMT with LS+rOPG and middle-point as a splitpoint
     parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        Model_rOPG = GOMT(dataTrain(:,1:end-1),dataTrain(:,end),'splitdirection','rOPG','plot',0,'report',0,'localModels','full','splitpoint','MIDDLE','notesize',2*(size(dataTrain,2)-1)+1);
        [rOPG_MAE, rOPG_RMSE, rOPG_predictions] = determineErrorGOMT(Model_rOPG, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = rOPG_RMSE;
        run(j).Predictions = rOPG_predictions;
        run(j).model = Model_rOPG;
        run(j).sizeModel = size(Model_rOPG,2);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GOMT_rOPG_MIDDLE_fullLM";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report MID-GOMT with rOPG:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

    %% GOMT with PHD and SUPPORT splitpoint-selection
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        Model_rOPG = GOMT(dataTrain(:,1:end-1),dataTrain(:,end),'splitdirection','PHD','plot',0,'report',0,'localModels','full','splitpoint','SUPPORT','notesize',2*(size(dataTrain,2)-1)+1);
        [rOPG_MAE, rOPG_RMSE, rOPG_predictions] = determineErrorGOMT(Model_rOPG, dataTest(:,1:end-1), dataTest(:,end));
        run(j).RMSE = rOPG_RMSE;
        run(j).Predictions = rOPG_predictions;
        run(j).model = Model_rOPG;
        run(j).sizeModel = size(Model_rOPG,2);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "GOMT_PHD_SUPPORT_fullLM";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report SUP-GOMT with PHD:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

    %% LSRT
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        ModeX = [1:size(dataTrain,2)-1];
        [SubLSTrees, LSRT] = PrunedLSRT(10, 1, size(dataTrain,2)-1, "AIC", 1, ModeX,[dataTrain(:,end) dataTrain(:,1:end-1)], 'CART',"LSstd");
        [ErrorLSRT, predictions] = determineSquaredTestErrorLSRT(LSRT, [dataTest(:,end), dataTest(:,1:end-1)], ModeX);
        run(j).RMSE = sqrt(ErrorLSRT);
        run(j).Predictions = predictions;
        run(j).model = LSRT;
        run(j).sizeModel = size(LSRT,1);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "LSRT_AICc";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report LSRT:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

    %% CART
    parfor (j=1:size(data(i).run,2),workers)
        dataTrain = data(i).run(j).train;
        dataTest = data(i).run(j).test;
        ModeX = [1:size(dataTrain,2)-1];
        [SubLSTrees, LSRT] = PrunedLSRT(10, 1, size(dataTrain,2)-1, "AIC", 1, ModeX,[dataTrain(:,end) dataTrain(:,1:end-1)], 'CART',"CART");
        [ErrorLSRT, predictions] = determineSquaredTestErrorLSRT(LSRT, [dataTest(:,end), dataTest(:,1:end-1)], ModeX);
        run(j).RMSE = sqrt(ErrorLSRT);
        run(j).Predictions = predictions;
        run(j).model = LSRT;
        run(j).sizeModel = size(LSRT,1);
    end
    benchmarking(k).dataset(i).meanRMSE = mean([run(1:end).RMSE]);
    benchmarking(k).dataset(i).sigmaRMSE = std([run(1:end).RMSE]);
    benchmarking(k).dataset(i).meanSize = mean([run(1:end).sizeModel]);
    benchmarking(k).dataset(i).sigmaSize = std([run(1:end).sizeModel]);
    benchmarking(k).model = "CART";
    benchmarking(k).dataset(i).function = data(i).function;
    benchmarking = setfield(benchmarking,{k},'dataset',{i},'run',run);
    clear run
    fprintf('Report CART:  Run %i with RMSE %f \n',i, round(benchmarking(k).dataset(i).meanRMSE,3))
    k = k+1;

%% save data after each iteration
save(filename,'data','benchmarking','seedData','seedBenchmarking');
end