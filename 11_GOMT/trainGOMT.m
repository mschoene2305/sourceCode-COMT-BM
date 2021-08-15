function [tree] = trainGOMT(X,y,options)
% author:       Marvin Schöne, Center for Applied Data Science Gütersloh,
%               University of Applied Sciences Bielefeld
% first draft:  20.05.2021 (finished at 08.07.2021)

% Elements of tree: tree.note, tree.parent, tree.splitratio, 
%                   tree.splitcrit, tree.splitpoint, tree.localModel,
%                   tree.RMSE, tree.response, tree.predictor

%% Construct root
index = 1;
tree(index).note = 1; tree(index).parent = 0; % assign index of current note and parent note
tree(index).predictor = X; tree(index).response = y; % assign samples to note

%% construct local model for root 
affineX = [ones(size(tree(index).predictor,1),1), tree(index).predictor];
if var(tree(index).response) > 0
    if options.localModels == "full" % construct local model without regularization
        if min(eig(affineX'*affineX)) > 0.0001
            tree(index).localModel = (affineX'*affineX)\affineX'*tree(index).response; % local model
            
        elseif size(tree(index).predictor,1) <= 2 % output-value is a constant
            tree(index).localModel = [mean(tree(index).response); zeros(size(tree(index).predictor,2))];
            
        else % singular matrix -> construct local model by first component of Partial Least Squares
            tree(index).localModel = firstCompPLS(tree(index).predictor,tree(index).response);
        end
           
    elseif options.localModels == "selectionAICc" % construct local model with backward- or forward-selection and AICc
        tree(index).localModel = ModelSelectionAICc(tree(index).response,affineX,[]);
        
    elseif options.localModels == "forwardAICc" % construct local model with backward- or forward-selection and AICc
        tree(index).localModel = ModelSelectionAICc(tree(index).response,affineX,zeros(size(tree(index).predictor,2)+1,1));
        
    else
        error('Please select an available method for local model estimation'); 
    end
    
else % output-value is a constant
    tree(index).localModel = [mean(tree(index).response); zeros(size(tree(index).predictor,2))];
end 
tree(index).RMSE = sqrt(mean((tree(index).response - affineX*tree(index).localModel).^2)); % RMSE of local model

%% recursive partitioning process
while index <= numel(tree)
    %% initialize parameters for each iteration
    [N, M] = size(tree(index).predictor);
    if index == 53
        stop = 1;
    end
    
    % check early stopping rules and determien either local model or split
    % note
    noteTerminal = 1;
    if min(tree(index).response) ~= max(tree(index).response) && options.notesize <= N % check if response contains same values and check simple-size within note
        for i=1:M
            if min(tree(index).predictor) ~= max(tree(index).predictor) % check if predictors only contain same values
                noteTerminal = 0;
            end
        end
    end
        
    %% estimate local model to construct terminal note or split note into two children
    if noteTerminal % construct local model    
        %% construct local model
        if options.localModels == "selectionAICc" 
            affineX = [ones(size(tree(index).predictor,1),1), tree(index).predictor];
            tree(index).localModel = ModelSelectionAICc(tree(index).response,affineX,tree(index).localModel);
            tree(index).RMSE = sqrt(mean((tree(index).response - affineX*tree(index).localModel).^2)); % RMSE of local model
        end
        
        %% display development process in case of local model estimation 
        if options.report
            % combine local model to string
            str = "y = ";
            if tree(index).localModel(1) > 0
                str = append(str,"+",string(round(tree(index).localModel(1),2))," ");
            else
                str = append(str,string(round(tree(index).localModel(1),2))," ");
            end
            
            for i=1:M
                if tree(index).localModel(i+1) > 0
                    str = append(str,"+");
                end
                str = append(str,string(round(tree(index).localModel(i+1),2)),"*x",string(i)," ");
            end
            % print report into command window
            fprintf('Report:  note %i is terminated and contains local model %s with RMSE %f \n',index, str, round(tree(index).RMSE,3))
        end
    
    else % split note
        %% determine splitdirection
        affineX = [ones(N,1), tree(index).predictor];
        if options.splitdirection == "rOPG"
            %% construct local model
            tree(index).direction.residuals = tree(index).response - affineX*tree(index).localModel;
            %% construct rOPG direction
            [rVec, ~, ~] = rOPG_adj(tree(index).predictor,tree(index).direction.residuals,1,20);
            tree(index).splitcrit = rVec(:,1);
            tree(index).direction.predictions = tree(index).predictor*tree(index).splitcrit;
            
        elseif options.splitdirection == "PHD"
            [tree(index).splitcrit, tree(index).direction.residuals] = PHD(tree(index).predictor, tree(index).response);
            tree(index).direction.predictions = tree(index).predictor*tree(index).splitcrit;

        else
            error('At this time, the only available option for splitdirection estimation is "rOPG" and "PHD".');
        end
        
        %% determine splitpoint
        if options.splitpoint == "SUPPORT"
            mask = tree(index).direction.residuals > 0;
            if sum(mask) ~= 0 && sum(mask) ~= N
                tree(index).splitpoint = (mean(tree(index).direction.predictions(mask)) + ...
                    mean(tree(index).direction.predictions(~mask)))/2;
            else
                tree(index).splitpoint = mean(tree(index).direction.predictions);
            end  
           
        elseif options.splitpoint == "HINGE_GLOBAL"
            tree(index).splitpoint = splitpointHingeGlobal(tree(index).direction.residuals,tree(index).direction.predictions);
        
        elseif options.splitpoint == "HINGE_LOCAL"
            tree(index).splitpoint = splitpointHingeLocal(tree(index).direction.residuals,tree(index).direction.predictions);
         
        elseif options.splitpoint == "MIDDLE"
            tree(index).splitpoint = min(tree(index).direction.predictions) + ...
                (max(tree(index).direction.predictions)-min(tree(index).direction.predictions))/2;
            
        else
            warning('At this time, the only available option for splitpoint detection is "SUPPORT" and "PHDRT".');
        end
        
        %% check prepruning criterion (if prepruning is selected in "options.pruning") 
        if options.pruning == "pre" % check pruning criterion before splitting
            %% METHODS FOR PREPRUNING WILL BE EXTENDED SOON (work in progress)
            noteTerminal = 1; % prepruning criterion activated
            
        else % if postpruning is selected, construct generalized linear model so that the node can also be used as a leaf
            if options.localModels == "selectionAICc" % construct local model with backward- or forward-selection and AICc
                tree(index).localModel = ModelSelectionAICc(tree(index).response,affineX,tree(index).localModel);
                tree(index).RMSE = sqrt(mean((tree(index).response - affineX*tree(index).localModel).^2)); % RMSE of local model
            end
        end

        %% split note into two children or construct local model (depends on prepruning criterion)
        if noteTerminal == 0 % split note into two children
            samplesLeft = tree(index).direction.predictions <= tree(index).splitpoint;
            %% construct left note
            indexChild = numel(tree)+1;
            tree(indexChild).note = indexChild; tree(indexChild).parent = index; % assign index of current note and parent note
            tree(indexChild).predictor = tree(index).predictor(samplesLeft,:); tree(indexChild).response = tree(index).response(samplesLeft,:); % assign samples to note
            
            % determine local model for left note
            affineX = [ones(size(tree(indexChild).predictor,1),1), tree(indexChild).predictor];
            if var(tree(indexChild).response) > 0
                if options.localModels == "full" % construct local model without regularization
                    if min(eig(affineX'*affineX)) > 0.0001
                        tree(indexChild).localModel = (affineX'*affineX)\affineX'*tree(indexChild).response; % local model
                        
                    elseif size(tree(indexChild).predictor,1) <= 2 % output-value is a constant
                        tree(indexChild).localModel = [mean(tree(indexChild).response); zeros(M,1)];
                        
                    else % singular matrix -> construct local model by first component of Partial Least Squares
                        tree(indexChild).localModel = firstCompPLS(tree(indexChild).predictor,tree(indexChild).response);
                    end
                    
                elseif options.localModels == "selectionAICc" % construct local model with backward- or forward-selection and AICc
                    tree(indexChild).localModel = ModelSelectionAICc(tree(indexChild).response,affineX,[]);

                elseif options.localModels == "forwardAICc" % construct local model with backward- or forward-selection and AICc
                    tree(indexChild).localModel = ModelSelectionAICc(tree(indexChild).response,affineX,zeros(M+1,1));
                    
                else
                    error('Please select an available method for local model estimation'); 
                end
                
            else % output-value is a constant
            	tree(indexChild).localModel = [mean(tree(indexChild).response); zeros(M,1)];
            end
            tree(indexChild).RMSE = sqrt(mean((tree(indexChild).response - affineX*tree(indexChild).localModel).^2)); % RMSE of local model
            
            %% construct right note
            indexChild = numel(tree)+1;
            tree(indexChild).note = indexChild; tree(indexChild).parent = index; % assign index of current note and parent note
            tree(indexChild).predictor = tree(index).predictor(~samplesLeft,:); tree(indexChild).response = tree(index).response(~samplesLeft,:); % assign samples to note
            
            % determine local model for right note
            affineX = [ones(size(tree(indexChild).predictor,1),1), tree(indexChild).predictor];
            if var(tree(indexChild).response) > 0
                if options.localModels == "full" % construct local model without regularization
                    if min(eig(affineX'*affineX)) > 0.0001
                        tree(indexChild).localModel = (affineX'*affineX)\affineX'*tree(indexChild).response; % local model
                        
                    elseif size(tree(indexChild).predictor,1) <= 2 % output-value is a constant
                        tree(indexChild).localModel = [mean(tree(indexChild).response); zeros(M,1)];
                        
                    else % singular matrix -> construct local model by first component of Partial Least Squares
                        tree(indexChild).localModel = firstCompPLS(tree(indexChild).predictor,tree(indexChild).response);
                    end

                elseif options.localModels == "selectionAICc" % construct local model with backward- or forward-selection and AICc
                    tree(indexChild).localModel = ModelSelectionAICc(tree(indexChild).response,affineX,[]);

                elseif options.localModels == "forwardAICc" % construct local model with backward- or forward-selection and AICc
                    tree(indexChild).localModel = ModelSelectionAICc(tree(indexChild).response,affineX,zeros(M+1,1));
                    
                else
                    error('Please select an available method for local model estimation'); 
                end
                
            else % output-value is a constant
            	tree(indexChild).localModel = [mean(tree(indexChild).response); zeros(M,1)];
            end
            tree(indexChild).RMSE = sqrt(mean((tree(indexChild).response - affineX*tree(indexChild).localModel).^2)); % RMSE of local model
            
            tree(index).splitratio = sum(samplesLeft)/N; % define ratio, how many samples are assigned to the left note           
            
            %% display development process in case of splitting
            if options.report
                % combine splitcriterion to string
                str = "";
                for i=1:M
                    if tree(index).splitcrit(i) > 0
                        str = append(str,"+");
                    end
                    str = append(str,string(round(tree(index).splitcrit(i),2)),"*x",string(i)," ");
                end
                str = append(str,"<= ",string(round(tree(index).splitpoint,2)));
                % print report into command window
                fprintf('Report:  note %i is split by %s\n',index, str)
            end
            
            if options.plot % plot resulting partitions in residual-response-graph of splitting direction
                scatterplot = figure;
                scatter(tree(index).direction.predictions(samplesLeft),tree(index).direction.residuals(samplesLeft));
                hold on;
                scatter(tree(index).direction.predictions(~samplesLeft),tree(index).direction.residuals(~samplesLeft));
                title(append("Resulting partitions from note ", string(index)));
                xlabel(str);
                ylabel('residuals');
                hold off;
                pause(2)    
                close(scatterplot);   
            end
            
        else % construct local model due to prepruning criterion (at first draft inactive)
            %% construct local model
            % due to the splittingmethod rOPG or PHD the full sized least
            % squares model(without restrictions) is still available
            if options.localModels == "selectionAICc" % further options for regularization will be addeted soon
                tree(index).localModel = ModelSelectionAICc(tree(index).response,affineX,tree(index).localModel);
                tree(index).RMSE = sqrt(mean((tree(index).response - affineX*tree(index).localModel).^2)); % RMSE of local model
            end
            
            %% display development process in case of local model estimation
            if options.report
                % combine local model to string
                str = "y = ";
                if tree(index).localModel(1) > 0
                    str = append(str,"+",string(round(tree(index).localModel(1),2))," ");
                    
                else
                    str = append(str,string(round(tree(index).localModel(1),2))," ");
                end

                for i=1:M
                    if tree(index).localModel(i+1) > 0
                        str = append(str,"+");
                    end
                    str = append(str,string(round(tree(index).localModel(i+1),2)),"*x",string(i)," ");
                end
                % print report into command window
                fprintf('Report:  note %i is terminated and contains local model %s\n',index, str)
            end
        end   
    end   
    
    index = index+1;
end
end

