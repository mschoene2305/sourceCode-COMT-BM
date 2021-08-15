function [GuideTree, k] = trainGuideTree(dataTrain,k,readMode,deleteMode,path)
%TRAINGUIDETREE Summary of this function goes here
%   Detailed explanation goes here
%% create data for training
% double('a') = 97
% PARAMETERS:
% readMode, deleteMode: select '1' for parfore Benchmarking
%filename = "53_GUIDE\dataTrainMask"+string(k)+".txt";
while isfile(path + "\dataTrainMask"+string(k)+".txt") && readMode
    %wait for deleting
    kNew = randi(30);
    pause(0.001);
    if kNew <= 9
        k = kNew; 
    end
end
fid = fopen(path+ "\dataTrainMask"+string(k)+".txt", 'wt' );
headerMask = "dataTrain"+string(k)+".txt\nNaN\n1\n";
fprintf(fid,headerMask);
sizeDatastes = size(dataTrain,2);
if sizeDatastes > 9
    mask = [num2str([1:9]'), char([97:(96+9)]'), char(ones(9,1)*97), char(ones(9,1)*110)]';
    formatSpec = '%c %c%c %c\n';
    fprintf(fid,formatSpec,mask);
    sizeDatastes = sizeDatastes-9;
    mask = [num2str([10:sizeDatastes+9]'), char([106:(105+sizeDatastes)]'), char(ones(sizeDatastes,1)*97), char(ones(sizeDatastes-1,1)*110,100)]';
    formatSpec = '%c%c %c%c %c\n';
    fprintf(fid,formatSpec,mask);
    
else
    mask = [num2str([1:size(dataTrain,2)]'), char([97:(96+size(dataTrain,2))]'), char(ones(size(dataTrain,2),1)*97), char(ones(size(dataTrain,2)-1,1)*110,100)]';
    formatSpec = '%c %c%c %c\n';
    fprintf(fid,formatSpec,mask);
end
fclose(fid);
% depends on the data set
fid = fopen(path+ "\dataTrain" +string(k)+".txt", 'wt' );

%% ÜBERARBEITEN!!!
functionMode = size(dataTrain,2);
if functionMode == 6
% for friedman-function
    formatSpec = '%f %f %f %f %f %f\n';
    
elseif functionMode == 3 
% for function 3
    formatSpec = '%f %f %f\n';   
    
elseif functionMode == 7
    formatSpec = '%f %f %f %f %f %f %f\n';
    
elseif functionMode == 8
    formatSpec = '%f %f %f %f %f %f %f %f\n';
    
elseif functionMode == 9 
% for function 3
    formatSpec = '%f %f %f %f %f %f %f %f %f\n';  

elseif functionMode == 11
    formatSpec = '%2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f\n';
    
elseif functionMode == 12
    formatSpec = '%2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f %2.7f\n';
    
elseif functionMode == 25
    formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';

elseif functionMode == 21
    formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';
    
elseif functionMode == 16
    formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';

elseif functionMode == 17
    formatSpec = '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n';
    
elseif functionMode == 30
    formatSpec = '%f %f %f %f %f %f %f %f %i %i\n';
end

fprintf(fid,formatSpec,dataTrain');
fclose(fid);


while isfile(path + "\regressionOut"+string(k)+".txt") && readMode
    %wait for deleting
end

%% train guide-tree
command = "cd " + path + " & guide < regressionIn"+string(k)+".txt";
[status,cmdout] = system(command);




%% read structure of guide-tree
fileID = fopen("regressionOut"+string(k)+".txt",'r');
formatSpec = '%c';
[structureTree,count] = fscanf(fileID, formatSpec);
fclose(fileID);

i=1;
structureDetected = false;
key.trigger = '***************************************************************';
key.sizeTrigger = size(key.trigger,2);
key.error = ' Error in PRINT_TREE';
key.sizeError = size(key.error,2);
key.node = 'Node ';
key.sizeNode = size(key.node,2);
key.splitnode = ' Intermediate node';
key.sizeSplitnode = size(key.splitnode,2);
key.terminalnode = ' Terminal node';
key.sizeTerminalnode = size(key.terminalnode,2);
key.threshold = '<= ';
key.sizeThreshold = size(key.threshold,2);
key.testCoeff = 'mean';
key.sizeTestCoeff = size(key.testCoeff,2);
key.endOfNode = '----------------------------';
key.sizeEndOfNode = size(key.endOfNode,2);
key.startFunction = 'Constant';
key.sizeStartFunction = size(key.startFunction,2);
GuideTree = cell(1,5);
GuideTree{1,1} = [1, 0];
dim = size(dataTrain,2);

while i <= size(structureTree,2)-key.sizeNode
    if structureDetected == false
        if structureTree(i+1:i+key.sizeError) == key.error
            GuideTree = [];
            break;
        elseif structureTree(i:i+key.sizeTrigger-1) == key.trigger
            structureDetected = true;
        
        end
    % a new node is detected   
    elseif structureTree(i:i+key.sizeNode-1) == key.node
        n = i+key.sizeNode;
        process = 0;
        while true
            switch process
                case 0 % find node-ID
                    nodeID = 0;
                    if structureTree(n+1) == ':'
                        nodeID = str2double(structureTree(n));
                        n = n+2;
                    elseif structureTree(n+2) == ':'
                        nodeID = str2double(structureTree(n:n+1));
                        n = n+3;
                    elseif structureTree(n+3) == ':'
                        nodeID = str2double(structureTree(n:n+2));
                        n = n+4;
                    elseif structureTree(n+4) == ':'
                        nodeID = str2double(structureTree(n:n+3));
                        n = n+5;
                    elseif structureTree(n+5) == ':'
                        nodeID = str2double(structureTree(n:n+4));
                        n = n+6;
                    elseif structureTree(n+6) == ':'
                        nodeID = str2double(structureTree(n:n+5));
                        n = n+7;
                    end
                    
                    if (nodeID > 0)
                        if (structureTree(n:n+key.sizeSplitnode-1) == key.splitnode)
                            process = 1;
                            n = n+key.sizeSplitnode;
                        elseif (structureTree(n:n+key.sizeTerminalnode-1) == key.terminalnode)
                            process = 4;
                            n = n+key.sizeTerminalnode;
                        else
                            error("missing node-information");
                        end
                    end

                case 1 % find left child
                    if structureTree(n:n+key.sizeNode-1) == key.node
                        n = n+key.sizeNode;
                        if structureTree(n+1) == ' '
                            nodeIDChildLeft = str2double(structureTree(n));
                            n = n+2+3;
                        elseif structureTree(n+2) == ' '
                            nodeIDChildLeft = str2double(structureTree(n:n+1));
                            n = n+3+3;
                        elseif structureTree(n+3) == ' '
                            nodeIDChildLeft = str2double(structureTree(n:n+2));
                            n = n+4+3;
                        elseif structureTree(n+4) == ' '
                            nodeIDChildLeft = str2double(structureTree(n:n+3));
                            n = n+5+3;
                        elseif structureTree(n+5) == ' '
                            nodeIDChildLeft = str2double(structureTree(n:n+4));
                            n = n+6+3;
                        elseif structureTree(n+6) == ' '
                            nodeIDChildLeft = str2double(structureTree(n:n+5));
                            n = n+7+3;
                        end
                        nodeIDChildRight = nodeIDChildLeft+1;
                        splitValue = double(structureTree(n))-double(structureTree(n+1))+1;
                        process = 2;
                    end
                case 2 % find threshold
                    if structureTree(n:n+key.sizeThreshold-1) == key.threshold
                        n = n+key.sizeThreshold;
                        m = n+1;
                        while true
                            if structureTree(m) == sprintf('\r')
                                break;
                            else
                                m = m+1;
                            end
                        end
                        threshold = str2double(structureTree(n:m-1));
                        process = 3;
                        n=m-1;
                    end
                case 3 % find breakpoint
                    if structureTree(n:n+key.sizeEndOfNode-1) == key.endOfNode
                        i = n+key.sizeEndOfNode-1;
                        buffer = zeros(1,dim-1);
                        buffer(splitValue) = 1;
                        GuideTree{nodeID,2} = buffer;
                        GuideTree{nodeID,3} = threshold;
                        GuideTree{nodeID,5} = [0.5 0.5];
                        GuideTree{nodeIDChildLeft,1} = [nodeIDChildLeft, nodeID];
                        GuideTree{nodeIDChildRight,1} = [nodeIDChildRight, nodeID];
                        break;
                    end
                case 4 % find constant part of function
                    if structureTree(n:n+key.sizeStartFunction-1) == key.startFunction
                        coefficients = zeros(1,dim);
                        n = n+key.sizeStartFunction;
                        while true
                            if structureTree(n) ~= ' '
                                m = n;
                                while true
                                    if structureTree(m) == ' '
                                        coefficients(1) = str2double(structureTree(n:m-1));
                                        process = 5;
                                        n = m-1;
                                        break;
                                    end
                                    m = m+1;
                                end
                                break;
                            end
                            n = n+1;
                        end
                    end
                case 5
                    endFunction = false;
                    while endFunction == false
                        if structureTree(n) == sprintf('\r')
                            n = n+1;
                            while true
                                if structureTree(n) ~= ' ' && structureTree(n) ~= sprintf('\n') && structureTree(n) ~= sprintf('\r')
                                    splitValue = double(structureTree(n))-double(structureTree(n+1))+1;
                                    n=n+2;
                                    break;
                                end
                                n = n+1;
                            end
                            
                            while true
                                if structureTree(n) ~= ' '
                                    if structureTree(n) == 'm'
                                        endFunction = true;
                                        process = 6;
                                    else
                                        m = n;
                                        while true
                                            if structureTree(m) == ' '
                                                coefficients(splitValue+1) = str2double(structureTree(n:m-1));
                                                process = 6;
                                                n = m-1;
                                                break;
                                            end
                                            m = m+1;
                                        end  
                                    end
                                    break;
                                end 
                                n = n+1; 
                            end  
                        end
                        n = n+1;  
                    end    
                case 6
                    if structureTree(n:n+key.sizeEndOfNode-1) == key.endOfNode
                        GuideTree{nodeID,4} = coefficients;
                        break;
                    end    
                otherwise
                    disp('other value')
            end
            n = n+1;
        end
    end
    i=i+1;
end

empyElements = [];
for i=1:size(GuideTree,1)
    if isempty(GuideTree{i,1})
        empyElements = [empyElements; i];
    end
end

GuideTree(empyElements,:) =[];

if deleteMode 
    delete(path + "\dataTrainMask"+string(k)+".txt");
    delete(path + "\regressionOut"+string(k)+".txt");
end

end

