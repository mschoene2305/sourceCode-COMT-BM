function [splitpoint] = splitpointHingeGlobal(y,X)
%SPLITPOINTHINGEGLOBAL Summary of this function goes here
%   Detailed explanation goes here
n = size(X,1);
hinge.coeffLeft = zeros(2,1);
hinge.coeffRight = zeros(2,1);
lambdaStart = 0.125;
lambda = lambdaStart;
splitpoint = 0;
convergenceIterations = 0;
reset = 0;
plot = 0;

if plot
    scatter(X,y);
end

%% initialization
mask = y > 0;
if sum(mask) ~= 0 && sum(mask) ~= n
    hinge.initial(1) = (mean(X(mask)) + ...
        mean(X(~mask)))/2;
else
    hinge.initial(1) = mean(X);
end

% calculate 4 additional starting points of hinge algorithm fails
hinge.initial(2) = min(X) + (hinge.initial(1)-min(X))*0.9; % left side from initial point
hinge.initial(3) = max(X) - (max(X)-hinge.initial(1))*0.9; % right side from initial point
hinge.initial(4) = min(X) + (hinge.initial(1)-min(X))*0.8; % left side from initial point
hinge.initial(5) = max(X) - (max(X)-hinge.initial(1))*0.8; % right side from initial point

affineX = [ones(n,1), X];
hinge.intersection = hinge.initial(1);
hinge.criterionMin = 0.5*sum((y-mean(y)).^2);


%% .................
%while abs(1-splitpoint/hinge.intersection) >= 0.05 || convergenceIterations < 2 
while 1-(abs(splitpoint-hinge.intersection)/(max(X)-min(X))) < 0.995 || convergenceIterations < 2 
    % check convergence
    if 1-(abs(splitpoint-hinge.intersection)/(max(X)-min(X))) >= 0.995
        convergenceIterations = convergenceIterations + 1;
    else
        convergenceIterations = 0;
    end
    
    splitpoint = hinge.intersection;
    hinge.dataLeft = affineX(X<splitpoint,:);
    hinge.dataRight = affineX(X>splitpoint,:);
    if plot
        scatter(X(X<=splitpoint),y(X<=splitpoint));
        hold on;
        scatter(X(X>splitpoint),y(X>splitpoint));
        hold off;      
    end
    
    if min(eig(hinge.dataLeft'*hinge.dataLeft)) > 0.0001 && min(eig(hinge.dataRight'*hinge.dataRight)) > 0.0001
        % update parameter
        coeffLeft = (hinge.dataLeft'*hinge.dataLeft)\hinge.dataLeft'*y(X<splitpoint);
        coeffRight = (hinge.dataRight'*hinge.dataRight)\hinge.dataRight'*y(X>splitpoint);
        
        hinge.coeffLeft = hinge.coeffLeft + lambda*(coeffLeft - hinge.coeffLeft);
        hinge.coeffRight = hinge.coeffRight + lambda*(coeffRight - hinge.coeffRight);

        % calculate point of intersection
        hinge.intersection = (hinge.coeffLeft(1)-hinge.coeffRight(1))/...
            (hinge.coeffRight(2)-hinge.coeffLeft(2));
        
        if hinge.intersection > min(X) && hinge.intersection < max(X)% check weather point of intersection is within partition area
            
            % calculate value of criterion
            hinge.yHatLeft = (y(X<hinge.intersection) - affineX(X<hinge.intersection,:)*hinge.coeffLeft).^2;
            hinge.yHatRight = (y(X>hinge.intersection) - affineX(X>hinge.intersection,:)*hinge.coeffRight).^2;
            hinge.criterion = 0.5*sum([hinge.yHatLeft; hinge.yHatRight]);
            
            if hinge.criterion > hinge.criterionMin
                lambda = lambda/2;
            else
                hinge.criterionMin = hinge.criterion;
            end
            
        elseif reset < (size(hinge.initial,2)-1) % select a new starting point for local search
            
            reset = reset+1;
            
            % reset
            hinge.coeffLeft = zeros(2,1);
            hinge.coeffRight = zeros(2,1);
            lambda = lambdaStart;
            convergenceIterations = 0;
            hinge.intersection = hinge.initial(reset+1);
            
        else
            splitpoint = hinge.initial(1);
            break;
        end
    
    elseif reset < (size(hinge.initial,2)-1) % select a new starting point for local search

        reset = reset+1;

        % reset
        hinge.coeffLeft = zeros(2,1);
        hinge.coeffRight = zeros(2,1);
        lambda = lambdaStart;
        convergenceIterations = 0;
        hinge.intersection = hinge.initial(reset+1);
        
    else
        splitpoint = hinge.initial(1);
        break;
    end

end
end

