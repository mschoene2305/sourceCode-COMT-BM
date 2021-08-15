function [Model] = GOMT(varargin)
% author:       Marvin Schöne, Center for Applied Data Science Gütersloh,
%               University of Applied Sciences Bielefeld
% first draft:  20.05.2021 (finished at 08.07.2021)
% changes:      

%% check input arguments and initialize input arguments
if numel(varargin) < 2 || ischar(varargin{1}) || ischar(varargin{2}) 
    error('GOMT:options','At least a matrix of predictors and an array of respones are necessary.');
else
    if size(varargin{1},1) ~= size(varargin{2},1)
        error('GOMT:options','Dimension of predictors and responses are not equal.');
    elseif size(varargin{2},2) > 1
        error('GOMT:options','Method is not able to perform on multi dimensional responses.');
    else
        [N, M] = size(varargin{1});
        X = varargin{1};
        y = varargin{2};
    end
    
end

%% set defaults and options
options = [];
options.plot = 0;
options.report = 1;
options.splitdirection = 'rOPG'; % 'PHD'
options.pruning = 'post'; % 'pre'
options.splitpoint = 'SUPPORT'; % 'HINGE_GLOBAL', 'HINGE_LOCAL', 'MIDDLE'
options.notesize = M+1;
options.localModels = 'full'; % 'selectionAICc', 'forwardAICc'

% Compare defaults and given options
while ~isempty(varargin)
    % Loop over all fieldnames
    if ischar(varargin{1})
        % If it is a string
        if any(strcmp(fieldnames(options), varargin{1}))
            % If field is specified in the inputs use it instead of defaults
            options.(varargin{1}) = varargin{2};
            % Erase the used entries.
            varargin([1 2]) = [];
        else
            error('GOMT:options','%s is an unknown option.',varargin{1})
        end
    else
        % Erase the non-option entries.
        varargin(1) = [];
    end
end

%% Build Tree
Model = trainGOMT(X,y,options);

%% Postpruning (if selected)
if options.pruning == "post"
    options.plot = 0;
    if options.report == 1
        fprintf('\n \nReport: Oversized tree is pruned backwards by Breimans´ minimal cost complexity pruning...\n')
    end
    Model = mCCPruningGOMT(Model,options);
end

end

