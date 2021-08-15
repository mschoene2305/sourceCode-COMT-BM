function [dataTrain,dataTest,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,plotOption)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% selection: selected function
% noisiPredictors: number of additional predictors without an impact on
%                   response
% noiseDBPredictors: noise-dB of selected noisi predictors
% noiseDBResponse: noise (in dB) for additive adding in response
% fixedPoints: fixed input-values to plot the function (x3 .. xm)
% Ntest: number of test-samples
% Ntrain: number of training-samples
% M: number of predictors (most functions are declared for a fixed number 
%       so that no values of M are necessary
% holdOnOff: just for further options
% seetMode: select data distribution: 0-> random equal distribution, 1->
%               sobolset, 2-> LHC-Design
% plotOption: option to plot selected function in x1 and x2 (not available
%               for function 18)

% -------------example-code-----------------------
% plotFigures = 1;
% selection = 14; 
% noisiPredictors = [];
% noiseDBPredictors = 0.0;
% noiseDBResponse = 0;
% fixedPoints = [0.5 0.5 0.5];
% Ntest = 2000;
% Ntrain = 200;
% M = 5;
% holdOnOff = 0;
% seetMode = 0;
% [dataTrain,dataTest,M,range,offset] = testfunctionGenerator(selection,noisiPredictors,...
%     noiseDBPredictors,noiseDBResponse,fixedPoints,Ntest,Ntrain,M,holdOnOff,seetMode,1);


dataTrain = [];
dataTest = [];
space = 40;
sizeLevels = 10;
switch selection
    % sinus-function with two predictors from zero to pi
    % the two predictors are interacting
    case 1
        range = pi;
        offset = 0;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 1.5*sin(U_GridMeshed1).*sin(U_GridMeshed2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 1.5*sin(dataTrain(:,1)).*sin(dataTrain(:,2));
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 1.5*sin(dataTest(:,1)).*sin(dataTest(:,2));
            dataTest = [dataTest yTest];
        end
        
    
    % 4-dimenional function with different cos,sin, squared and linear influence from zero to pi  
    % there are also interactions included
    case 2
        range = pi;
        offset = 0;
        M = 4;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 0.4*(U_GridMeshed1.^2) + 0.5.*U_GridMeshed1 + ...
            U_GridMeshed2.*cos(U_GridMeshed1).*cos(U_GridMeshed2) + ...
            0.3.*U_GridMeshed2.*U_fixed(1) + sin(U_fixed(2));
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 0.4*(dataTrain(:,1).^2) + 0.5.*dataTrain(:,1) + ...
                dataTrain(:,2).*cos(dataTrain(:,1)).*cos(dataTrain(:,2)) + ...
                0.3.*dataTrain(:,2).*dataTrain(:,3) + sin(dataTrain(:,4));
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 0.4*(dataTest(:,1).^2) + 0.5.*dataTest(:,1) + ...
                dataTest(:,2).*cos(dataTest(:,1)).*cos(dataTest(:,2)) + ...
                0.3.*dataTest(:,2).*dataTest(:,3) + sin(dataTest(:,4));
            dataTest = [dataTest yTest];
        end
    
    case 3
        range = 2;
        offset = -1;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 1.5*U_GridMeshed1 + 0.5*U_GridMeshed2 + ...
            5*U_GridMeshed1.*U_GridMeshed2 + 1*(U_GridMeshed1.^2) + ...
            1*(U_GridMeshed2.^2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 1.5*dataTrain(:,1) + 0.5*dataTrain(:,2) + ...
                5*dataTrain(:,1).*dataTrain(:,2) + 1*(dataTrain(:,1).^2) + ...
                1*(dataTrain(:,2).^2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 1.5*dataTest(:,1) + 0.5*dataTest(:,2) + ...
                5*dataTest(:,1).*dataTest(:,2) + 1*(dataTest(:,1).^2) + ...
                1*(dataTest(:,2).^2);
            dataTest = [dataTest yTest];
        end
        
    % 2-dimenional exponential function 
    % there are also interactions included
    case 4
        range = 2;
        %range = 1;
        offset = -1;
        %offset = 0;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = exp(-(U_GridMeshed1.^2+U_GridMeshed2.^2)./2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = exp(-(dataTrain(:,1).^2+dataTrain(:,2).^2)./2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = exp(-(dataTest(:,1).^2+dataTest(:,2).^2)./2);
            dataTest = [dataTest yTest];
        end
        
    case 5
        range = pi/2;
        offset = 0;
        %M = M;
        if round(M/3) ~= (M/3)
            error('If function 5 is chosen, M has to be 3-dimensional or multiples of 3');
        end
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        for i=1:M/3
            if i == 1
                y = (U_GridMeshed1.^2) + U_GridMeshed2 + U_fixed(1).*cos(U_GridMeshed1).*cos(U_GridMeshed2);
            else
                y = y + (1/(i^2)).*((U_fixed((i-1)*3 -1).^2) + U_fixed((i-1)*3) + U_fixed((i-1)*3 +1).*...
                    cos(U_fixed((i-1)*3 -1)).*cos(U_fixed((i-1)*3)));
            end
        end
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            for i=1:M/3
                if i == 1
                    yTrain = (dataTrain(:,(i*3)-2).^2) + dataTrain(:,(i*3)-1) + dataTrain(:,i*3).*...
                        cos(dataTrain(:,(i*3)-2)).*cos(dataTrain(:,(i*3)-1));
                else
                    yTrain = yTrain + (1/(i^2)).*((dataTrain(:,(i*3)-2).^2) + dataTrain(:,(i*3)-1) + dataTrain(:,i*3).*...
                        cos(dataTrain(:,(i*3)-2)).*cos(dataTrain(:,(i*3)-1)));
                end
            end
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            for i=1:M/3
                if i == 1
                    yTest = (dataTest(:,(i*3)-2).^2) + dataTest(:,(i*3)-1) + dataTest(:,i*3).*...
                        cos(dataTest(:,(i*3)-2)).*cos(dataTest(:,(i*3)-1));
                else
                    yTest = yTest + (1/(i^2)).*((dataTest(:,(i*3)-2).^2) + dataTest(:,(i*3)-1) + dataTest(:,i*3).*...
                        cos(dataTest(:,(i*3)-2)).*cos(dataTest(:,(i*3)-1)));
                end
            end
            dataTest = [dataTest yTest];
        end
        
    case 6
        range = 1;
        offset = 0;
        %M = M;
        if round(M/5) ~= (M/5)
            error('If function 6 is chosen, M has to be 5-dimensional or multiples of 5');
        end
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        for i=1:M/5
            if i == 1
                y = 10.*sin(pi.*U_GridMeshed1.*U_GridMeshed2) +...
                    20*(U_fixed(1)-0.5).^2 + 10*U_fixed(2) + 5*U_fixed(3);
            else
                y = y + (1/(i^2)).*(10.*sin(pi.*U_fixed((i-1)*5 -1).*U_fixed((i-1)*5))...
                    + 20.*(U_fixed((i-1)*5 +1)-0.5).^2 + 10.*U_fixed((i-1)*5 +2)...
                    + 5.*U_fixed((i-1)*5 +3));
            end
        end
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            for i=1:M/5
                if i == 1
                    yTrain = 10.*sin(pi.*dataTrain(:,1).*dataTrain(:,2)) +...
                        20.*(dataTrain(:,3)-0.5).^2 + 10.*dataTrain(:,4) + 5.*dataTrain(:,5);
                else
                    yTrain = yTrain + (1/(i^2)).*(10.*sin(pi.*dataTrain(:,(i*5)-4).*dataTrain(:,(i*5)-3))...
                        + 20.*(dataTrain(:,(i*5)-2)-0.5).^2 + 10.*dataTrain(:,(i*5)-1)...
                        + 5.*dataTrain(:,(i*5)));
                end
            end
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            for i=1:M/5
                if i == 1
                    yTest = 10.*sin(pi.*dataTest(:,1).*dataTest(:,2)) +...
                        20.*(dataTest(:,3)-0.5).^2 + 10.*dataTest(:,4) + 5.*dataTest(:,5);
                else
                    yTest = yTest + (1/(i^2)).*(10.*sin(pi.*dataTest(:,(i*5)-4).*dataTest(:,(i*5)-3))...
                        + 20.*(dataTest(:,(i*5)-2)-0.5).^2 + 10.*dataTest(:,(i*5)-1)...
                        + 5.*dataTest(:,(i*5)));
                end
            end
            dataTest = [dataTest yTest];
        end
        
    case 7
        range = pi/2;
        offset = 0;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = (U_GridMeshed1.^2) + U_GridMeshed2 + cos(U_GridMeshed1).*cos(U_GridMeshed2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = (dataTrain(:,1).^2) + dataTrain(:,2) + ...
                cos(dataTrain(:,1)).*cos(dataTrain(:,2));

        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = (dataTest(:,1).^2) + dataTest(:,2) +...
                cos(dataTest(:,1)).*cos(dataTest(:,2));

            dataTest = [dataTest yTest];
        end
        
     case 8
        range = 2;
        offset = 0;
        M = 2;
        
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = U_GridMeshed1.*U_GridMeshed2;
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = dataTrain(:,1).*dataTrain(:,2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = dataTest(:,1).*dataTest(:,2);
            dataTest = [dataTest yTest];
        end
        
    case 9
        range = 1;
        offset = 0;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 10.*sin(pi.*U_GridMeshed1.*U_GridMeshed2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 10.*sin(pi.*dataTrain(:,1).*dataTrain(:,2));

        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 10.*sin(pi.*dataTest(:,1).*dataTest(:,2));
            
            %(dataTest(:,1).^2) + dataTest(:,2) +...
                %cos(dataTest(:,1)).*cos(dataTest(:,2));

            dataTest = [dataTest yTest];
        end
     case 10
        range = 2;
        offset = -1;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 5*U_GridMeshed1.*U_GridMeshed2 + 1*(U_GridMeshed1.^2) + ...
            1*(U_GridMeshed2.^2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 5*dataTrain(:,1).*dataTrain(:,2) + 1*(dataTrain(:,1).^2) + ...
                1*(dataTrain(:,2).^2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 5*dataTest(:,1).*dataTest(:,2) + 1*(dataTest(:,1).^2) + ...
                1*(dataTest(:,2).^2);
            dataTest = [dataTest yTest];
        end
    
    case 11
        range = 1.25;
        offset = -0.25;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 1.5*U_GridMeshed1.*U_GridMeshed2 + 1*(U_GridMeshed1.^2) + ...
            1*(U_GridMeshed2.^2);
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 1.5*dataTrain(:,1).*dataTrain(:,2) + 1*(dataTrain(:,1).^2) + ...
                1*(dataTrain(:,2).^2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 1.5*dataTest(:,1).*dataTest(:,2) + 1*(dataTest(:,1).^2) + ...
                1*(dataTest(:,2).^2);
            dataTest = [dataTest yTest];
        end
    case 12 %% schiefe Friedman-Funktion mit nur 3 Eingangsgrößen
        range = 2;
        offset = 0;
        M = 3;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 10.*sin(pi.*U_GridMeshed1.*U_GridMeshed2) + 5.*cos((pi/2).*U_GridMeshed1) + 0.5*(U_fixed(1)-1).^2;
        surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
        xlabel('u1');
        ylabel('u2');
        zlabel('y');
        
        if Ntrain > 0
            hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 10.*sin(pi.*dataTrain(:,1).*dataTrain(:,2)) + 5.*cos((pi/2).*dataTrain(:,1)) + 0.5*(dataTrain(:,3)-1).^2;

        elseif holdOnOff
            hold on;
        else
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 10.*sin(pi.*dataTest(:,1).*dataTest(:,2)) + 5.*cos((pi/2).*dataTest(:,1)) + 0.5*(dataTest(:,3)-1).^2;

            dataTest = [dataTest yTest];
        end
    
    case 13 %% schiefe Friedman-Funktion mit nur 3 Eingangsgrößen
        range = 2;
        offset = 0;
        M = 3;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 10.*sin(pi.*U_GridMeshed1.*U_GridMeshed2) + 5.*cos((pi/2).*U_GridMeshed1) + 0.75*(U_fixed(1)-1).^2;
        surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
        xlabel('u1');
        ylabel('u2');
        zlabel('y');
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (0.6*randn(Ntrain,M)) + 1.1;
            end
            yTrain = 10.*sin(pi.*dataTrain(:,1).*dataTrain(:,2)) + 5.*cos((pi/2).*dataTrain(:,1)) + 0.75*(dataTrain(:,3)-1).^2;

        elseif holdOnOff
            hold on;
        else
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (0.5*randn(Ntest,M)) + 1;;
            end
            yTest = 10.*sin(pi.*dataTest(:,1).*dataTest(:,2)) + 5.*cos((pi/2).*dataTest(:,1)) + 0.75*(dataTest(:,3)-1).^2;

            dataTest = [dataTest yTest];
        end
        
    case 14 %Friedman-Funktion 
        range = [2 2 1 1 1];
        offset = 0;
        %M = M;
        if round(M/5) ~= (M/5)
            error('If function 6 is chosen, M has to be 5-dimensional or multiples of 5');
        end
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range(i),space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        for i=1:M/5
            if i == 1
                y = 10.*sin(pi.*U_GridMeshed1.*U_GridMeshed2) +...
                    20*(U_fixed(1)-1).^2 + 10*U_fixed(2) + 5*U_fixed(3);
            else
                y = y + (1/(i^2)).*(10.*sin(pi.*U_fixed((i-1)*5 -1).*U_fixed((i-1)*5))...
                    + 20.*(U_fixed((i-1)*5 +1)-1).^2 + 10.*U_fixed((i-1)*5 +2)...
                    + 5.*U_fixed((i-1)*5 +3));
            end
        end
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;    
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            for i=1:M/5
                if i == 1
                    yTrain = 10.*sin(pi.*dataTrain(:,1).*dataTrain(:,2)) +...
                        20.*(dataTrain(:,3)-1).^2 + 10.*dataTrain(:,4) + 5.*dataTrain(:,5);
                else
                    yTrain = yTrain + (1/(i^2)).*(10.*sin(pi.*dataTrain(:,(i*5)-4).*dataTrain(:,(i*5)-3))...
                        + 20.*(dataTrain(:,(i*5)-2)-1).^2 + 10.*dataTrain(:,(i*5)-1)...
                        + 5.*dataTrain(:,(i*5)));
                end
            end
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            for i=1:M/5
                if i == 1
                    yTest = 10.*sin(pi.*dataTest(:,1).*dataTest(:,2)) +...
                        20.*(dataTest(:,3)-1).^2 + 10.*dataTest(:,4) + 5.*dataTest(:,5);
                else
                    yTest = yTest + (1/(i^2)).*(10.*sin(pi.*dataTest(:,(i*5)-4).*dataTest(:,(i*5)-3))...
                        + 20.*(dataTest(:,(i*5)-2)-1).^2 + 10.*dataTest(:,(i*5)-1)...
                        + 5.*dataTest(:,(i*5)));
                end
            end
            dataTest = [dataTest yTest];
        end
    
    case 15 % monkey saddle
        range = 2;
        offset = -1;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = U_GridMeshed1.^3 - 3*U_GridMeshed1.*U_GridMeshed2.^2;
        
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = dataTrain(:,1).^3 - 3*dataTrain(:,1).*dataTrain(:,2).^2;
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = dataTest(:,1).^3 - 3*dataTest(:,1).*dataTest(:,2).^2;
            dataTest = [dataTest yTest];
        end
    
    case 16 %% MASAL function
        range = 0.99;
        offset = 1-range;
        M = 7;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = exp(3*U_GridMeshed1 - U_GridMeshed2 + U_fixed(1))./3 + 2*sin(pi*(U_fixed(2)-U_fixed(3))) ...
            + 2*log((2*U_fixed(4)+U_fixed(5))./(3-(2*U_fixed(4)+U_fixed(5))));
        
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
           % hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = exp(3.*dataTrain(:,1) - dataTrain(:,2) + dataTrain(:,3))./3 + 2.*sin(pi.*(dataTrain(:,4)-dataTrain(:,5))) ...
            + 2.*log((2.*dataTrain(:,6)+dataTrain(:,7))./(3-2.*dataTrain(:,6)-dataTrain(:,7)));

        elseif holdOnOff
            hold on;
        else
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = exp(3.*dataTest(:,1) - dataTest(:,2) + dataTest(:,3))./3 + 2.*sin(pi.*(dataTest(:,4)-dataTest(:,5))) ...
            + 2.*log((2.*dataTest(:,6)+dataTest(:,7))./(3-2.*dataTest(:,6)-dataTest(:,7)));
        
            dataTest = [dataTest yTest];
        end
        
    case 17 %% Friedman2 function
        range = 1;
        offset = 0;
        M = 10;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 0.1.*exp(4.*U_GridMeshed1) + 4./(1 + exp(-20.*(U_GridMeshed2-0.5))) + ...
            3.*U_fixed(1)* + 2.*U_fixed(2)* + U_fixed(3); 

        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 0.1.*exp(4.*dataTrain(:,1)) + 4./(1 + exp(-20.*(dataTrain(:,2)-0.5))) + ...
            3.*dataTrain(:,3) + 2.*dataTrain(:,4) + dataTrain(:,5); 

        elseif holdOnOff
            hold on;
        else
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 0.1.*exp(4.*dataTest(:,1)) + 4./(1 + exp(-20.*(dataTest(:,2)-0.5))) + ...
            3.*dataTest(:,3) + 2.*dataTest(:,4) + dataTest(:,5); 
        
            dataTest = [dataTest yTest];
        end
        
    case 18 %% PHDRT function
        range = 2;
        offset = -1;
        M = 10;
        plotOption = 0;
        beta1 = zeros(10,1);
        beta1(1:5,:) = [1; 1; 1; 1; 1];
        beta2 = zeros(10,1);
        beta2(6:end,:) = [1; 1; 1; 1; 1];
        
        if Ntrain > 0
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            
            yTrain = zeros(Ntrain,1);
            
            for i=1:Ntrain
                if (dataTrain(i,:)*beta2 >= 0) && ((dataTrain(i,:)*beta1*sqrt(3) + dataTrain(i,:)*beta2) >= 0)
                    yTrain(i) = - dataTrain(i,:)*beta1 - dataTrain(i,:)*beta2*sqrt(3) + 1;
                    
                elseif (dataTrain(i,:)*beta2 < 0) && ((dataTrain(i,:)*beta1*sqrt(3) - dataTrain(i,:)*beta2) >= 0)
                    yTrain(i) = - dataTrain(i,:)*beta1 + dataTrain(i,:)*beta2*sqrt(3) + 1;
                    
                elseif ((dataTrain(i,:)*beta1*sqrt(3) + dataTrain(i,:)*beta2) < 0) && ((dataTrain(i,:)*beta1*sqrt(3) - dataTrain(i,:)*beta2) < 0)
                    yTrain(i) = dataTrain(i,:)*beta1*2 + 1;
                    
                end    
            end
            
        elseif holdOnOff
            hold on;
        else
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = zeros(Ntest,1);
            
            for i=1:Ntest
                if (dataTest(i,:)*beta2 >= 0) && ((dataTest(i,:)*beta1*sqrt(3) + dataTest(i,:)*beta2) >= 0)
                    yTest(i) = - dataTest(i,:)*beta1 - dataTest(i,:)*beta2*sqrt(3) + 1;
                    
                elseif (dataTest(i,:)*beta2 < 0) && ((dataTest(i,:)*beta1*sqrt(3) - dataTest(i,:)*beta2) >= 0)
                    yTest(i) = - dataTest(i,:)*beta1 + dataTest(i,:)*beta2*sqrt(3) + 1;
                    
                elseif ((dataTest(i,:)*beta1*sqrt(3) + dataTest(i,:)*beta2) < 0) && ((dataTest(i,:)*beta1*sqrt(3) - dataTest(i,:)*beta2) < 0)
                    yTest(i) = dataTest(i,:)*beta1*2 + 1;
                    
                end    
            end
        
            dataTest = [dataTest yTest];
        end
    case 19
        range = 1.3;
        offset = 0;
        M = 2;
        for i=1:M
            if i < 3
                U_Grid(i,:) = linspace(0,1*range,space)+offset;
            elseif size(fixedPoints,2) == 1    
                U_fixed(1,i-2) = fixedPoints;
            else
                U_fixed(1,i-2) = fixedPoints(i-2);
            end
        end
        [U_GridMeshed1, U_GridMeshed2] = meshgrid(U_Grid);
        y = 1.5*U_GridMeshed1 + 0.5*U_GridMeshed2.^4;% + 0.5*U_GridMeshed1.*U_GridMeshed2;
        if plotOption
            surf(U_GridMeshed1,U_GridMeshed2,y,'FaceAlpha',0.8);
            xlabel('u1');
            ylabel('u2');
            zlabel('y');
        end
        
        if Ntrain > 0
            %hold on;
            if seetMode == 1
                set = sobolset(M);
                dataTrain = (range.*net(set,Ntrain)) + offset;
            elseif seetMode == 2
                dataTrain = (range.*DetOptlhsDesign(lhsdesign(Ntrain,M),'worstDistance2improve', sizeLevels)) + offset;
            else
                dataTrain = (range.*rand(Ntrain,M)) + offset;
            end
            yTrain = 1.5*dataTrain(:,1) + 0.5*dataTrain(:,2).^4;% + 0.5*dataTrain(:,1).*dataTrain(:,2);
        elseif holdOnOff
            hold on;
        elseif plotOption
            hold off;
        end
        
        if Ntest > 0
            if seetMode == 1
                set = sobolset(M);
                dataTest = (range.*net(set,Ntest)) + offset;
            else
                dataTest = (range.*rand(Ntest,M)) + offset;
            end
            yTest = 1.5*dataTest(:,1) + 0.5*dataTest(:,2).^4;% + 0.5*dataTest(:,1).*dataTest(:,2);
            dataTest = [dataTest yTest];
        end
            
    otherwise
        error('wrong value for parameter selection');
end

if noisiPredictors > 0
    M = M+noisiPredictors;
    if Ntrain > 0
        dataTrain = [dataTrain (randn(Ntrain,noisiPredictors).*sqrt(noiseDBPredictors)+(range./2))];
    end
    if Ntest > 0
        dataTest = [dataTest(:,1:end-1) (randn(Ntest,noisiPredictors).*sqrt(noiseDBPredictors)+(range./2)) dataTest(:,end)];
    end
end

if noiseDBResponse > 0 && Ntrain > 0
    dataTrain = [dataTrain yTrain + randn(Ntrain,1).*sqrt(noiseDBResponse)];
    if plotOption
        hold on;
        title('Testfunktion mit verrauschten Trainingsdatenpunkten (rot)');
        scatter3(dataTrain(:,1),dataTrain(:,2),dataTrain(:,end),'filled','red');
        hold off;
    end
elseif Ntrain > 0
    dataTrain = [dataTrain yTrain];
    if plotOption
        hold on;
        title('Testfunktion mit Trainingsdatenpunkten (rot)');
        scatter3(dataTrain(:,1),dataTrain(:,2),dataTrain(:,end),'filled','red');
        hold off;
    end
end

if holdOnOff
    hold on;
elseif plotOption
    hold off;
end
end

