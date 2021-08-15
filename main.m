clear
addpath('01_workspace')
addpath('10_General_Functions')

% %% load data set
% load('benchmarking_synthetic_data_final_20210708.mat')

%% construct synthetic Data
clear;
clc;
seedS = 3;
runsS = 150;
constructionSynthetic04072021();

%% start Benchmarking 1
addInfo = "_finalBM_GOMTrOPG_GOMTphd_LSRT_CART";
Benchmarking08072021_GOMT_LSRT_CART();

%% start Benchmarking 2
addInfo = "_finalBM_GUIDE";
Benchmarking08072021_GUIDE();

%% start Benchmarking 3
addInfo = "_finalBM_M5";
Benchmarking09072021_M5();