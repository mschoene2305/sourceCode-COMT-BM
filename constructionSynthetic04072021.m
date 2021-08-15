%%
rng('default')
seedData = seedS;
rng(seedData)
runs = runsS;

for i=1:runs
    k=1;
    %% data set 1: Friedman function 150 data points
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 150;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_n150";
    k = k+1;

    %% data set 2: Friedman function 300 data points
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 300;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_n300";
    k = k+1;
   
    %% data set 3: Friedman function 150 data points
    selection = 14;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 200;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_extension_x1x2_n150";
    k = k+1;

    %% data set 4: Friedman function 400 data points
    selection = 14;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 400;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_extension_x1x2_n400";
    k = k+1;
    
    %% data set 5: Friedman function with 20 dimensions 250 data points
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 250;
    M = 20;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_extension_m20_n250";
    k = k+1;

    %% data set 6: Friedman function with 20 dimensions 500 data points
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 500;
    M = 20;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_extension_m20_n500";
    k = k+1;

    %% data set 7: Friedman function 300 data points + noise 0.5
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0.5;
    fixedPoints = [0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 300;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_noise05_n300";
    k = k+1;
    
    %% data set 8: Friedman function 300 data points + noise 1
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 1;
    fixedPoints = [0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 300;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_noise1_n300";
    k = k+1;
    
    %% data set 9: Friedman function 300 data points + noise 2
    selection = 6;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 2;
    fixedPoints = [0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 300;
    M = 5;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "Friedman_noise2_n300";
    k = k+1;
    
    %% data set 10: Monkel Saddle 150 data points
    selection = 15;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0.0;
    Ntest = 2000;
    Ntrain = 150;
    M = 2;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "MonkeySaddle_n150";
    k = k+1;
    
    %% data set 11: Monkel Saddle 300 data points
    selection = 15;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0.0;
    Ntest = 2000;
    Ntrain = 300;
    M = 2;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "MonkeySaddle_n300";
    k = k+1;
    
    %% data set 12: Extention MARS function 200 data points
    selection = 16;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 200;
    M = 7;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "MASAL_n200";
    k = k+1;
    
    %% data set 13: Extention MARS function 400 data points
    selection = 16;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 400;
    M = 7;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "MASAL_n400";
    k = k+1;
    
    %% data set 14: Extention MARS function 400 data points + noise
    selection = 16;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 1;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 400;
    M = 7;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "MASAL_noise1_n400";
    k = k+1;
    
    %% data set 15: 2nd Friedman function 200 data points
    selection = 17;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 200;
    M = 10;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "2ndFriedman_n200";
    k = k+1;
    
    %% data set 16: 2nd Friedman function 400 data points
    selection = 17;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 400;
    M = 10;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "2ndFriedman_n400";
    k = k+1;
    
    %% data set 17: PHDRT function 200 data points
    selection = 18;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0 0 0 0 0 0 0 0];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 200;
    M = 10;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "PHDRT_n200";
    k = k+1;
    
    %% data set 18: PHDRT function 400 data points
    selection = 18;
    noisiPredictors = [];
    noiseDBPredictors = 0.0;
    noiseDBResponse = 0;
    fixedPoints = [0 0 0 0 0 0 0 0];
    %fixedPoints = [0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4];
    Ntest = 2000;
    Ntrain = 400;
    M = 10;
    holdOnOff = 0;
    seetMode = 0;
    [data(k).run(i).train,data(k).run(i).test,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
        noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,0);
    data(k).function = "PHDRT_n400";
    k = k+1;
end

save('benchmarking_synthetic_data.mat','seedData','runs','data');