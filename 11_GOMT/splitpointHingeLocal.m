function [splitpoint] = splitpointHingeLocal(y,X)
%SPLITPOINTHINGELOCAL Summary of this function goes here
%   Detailed explanation goes here
n = size(X,1);
h = 2.34*n^(-1/9); % kernel bandwidth
%h = 2.34*n^(-1/9); % kernel bandwidth
%h = 6*n^(-1/3); % kernel bandwidth
hinge.coeffLeft = zeros(2,1);
hinge.coeffRight = zeros(2,1);
hinge.fitnesvalue = ones(5,1)*Inf;
lambdaStart = 0.125;
lambda = lambdaStart;
splitpoint = Inf;
convergenceIterations = 0;
reset = 0;
plotOption = 0;
ratio = 1;

if plotOption
    scatter(X,y);
end

%% standardize data
varX = var(X); varY = var(y);
meanX = mean(X); meanY = mean(y);
sdX = (X - meanX)./sqrt(varX); sdY = (y - meanY)/sqrt(varY);

%% initialization
mask = sdY > 0;
if sum(mask) ~= 0 && sum(mask) ~= n
    hinge.initial(1) = (mean(sdX(mask)) + ...
        mean(sdX(~mask)))/2;
else
    hinge.initial(1) = mean(sdX);
end

% calculate 4 additional starting points of hinge algorithm fails
hinge.initial(2) = min(sdX) + (hinge.initial(1)-min(sdX))*0.9; % left side from initial point
hinge.initial(3) = max(sdX) - (max(sdX)-hinge.initial(1))*0.9; % right side from initial point
hinge.initial(4) = min(sdX) + (hinge.initial(1)-min(sdX))*0.8; % left side from initial point
hinge.initial(5) = max(sdX) - (max(sdX)-hinge.initial(1))*0.8; % right side from initial point

affineX = [ones(n,1), sdX];
hinge.intersection = hinge.initial(1);
W = exp((-1*abs(sdX-hinge.intersection).^2)/(2*h^2)); % determine Kernel weights
hinge.criterionMin = 0.5*sum((W).*(sdY-mean(sdY)).^2);
hinge.weightsLeft = W(sdX<hinge.intersection,:);
hinge.weightsRight = W(sdX>hinge.intersection,:);


%% .................
%while abs(1-splitpoint/hinge.intersection) >= 0.05 || convergenceIterations < 2 
while 1-(abs(splitpoint-hinge.intersection)/(max(sdX)-min(sdX))) < 0.995 || convergenceIterations < 2 || ratio >= 0.05
    % check convergence
    if (1-(abs(splitpoint-hinge.intersection)/(max(sdX)-min(sdX))) >= 0.995) && ratio < 0.05
        convergenceIterations = convergenceIterations + 1;
    else
        convergenceIterations = 0;
    end
    
    splitpoint = hinge.intersection;
%    W = exp((-1*abs(sdX-splitpoint).^2)/(2*h^2)); % determine Kernel weights
    hinge.dataLeft = affineX(sdX<splitpoint,:);
    hinge.dataRight = affineX(sdX>splitpoint,:);
   
    if plotOption
        scatter(sdX(sdX<=splitpoint),sdY(sdX<=splitpoint));
        hold on;
        %scatter(sdX(sdX<splitpoint),hinge.weightsLeft);
        scatter(sdX(sdX>splitpoint),sdY(sdX>splitpoint));
        %scatter(sdX(sdX>splitpoint),hinge.weightsRight);
        [sorted, index] = sort(sdX);
        plot(sorted,W(index));
        x = [((-2 -hinge.coeffLeft(1))/hinge.coeffLeft(2)), -2]
        y = [-2, (hinge.coeffLeft(1) - hinge.coeffLeft(2)*2)]
        line(x,y)
        
        x = [((-2 -hinge.coeffRight(1))/hinge.coeffRight(2)), +2]
        y = [-2, (hinge.coeffRight(1) + hinge.coeffRight(2)*2)]
        line(x,y)
        
        hold off;      
    end
    
    if min(eig(hinge.dataLeft'*hinge.dataLeft)) > 0.0001 && min(eig(hinge.dataRight'*hinge.dataRight)) > 0.0001
        % update parameter
        coeffLeft = (hinge.dataLeft'*diag(hinge.weightsLeft)*hinge.dataLeft)\hinge.dataLeft'*...
                    diag(hinge.weightsLeft)*sdY(sdX<splitpoint);
        coeffRight = (hinge.dataRight'*diag(hinge.weightsRight)*hinge.dataRight)\hinge.dataRight'*...
                     diag(hinge.weightsRight)*sdY(sdX>splitpoint);
        
        hinge.coeffLeftPrevious = hinge.coeffLeft;
        hinge.coeffLeft = hinge.coeffLeft + lambda*(coeffLeft - hinge.coeffLeft);
        hinge.coeffRightPrevious = hinge.coeffRight;
        hinge.coeffRight = hinge.coeffRight + lambda*(coeffRight - hinge.coeffRight);
        % calculate additional convergence-value
        ratio = abs(1-mean((abs(hinge.coeffLeft./hinge.coeffLeftPrevious)+abs(hinge.coeffRight./hinge.coeffRightPrevious))./2));
%abs(1-mean(abs(mean(ratio)))) < 0.025
        % calculate point of intersection
        hinge.intersection = (hinge.coeffLeft(1)-hinge.coeffRight(1))/...
            (hinge.coeffRight(2)-hinge.coeffLeft(2));
        
        if hinge.intersection > min(sdX) && hinge.intersection < max(sdX)% check weather point of intersection is within partition area
             
            % update kernel
            W = exp((-1*abs(sdX-hinge.intersection).^2)/(2*h^2)); % determine Kernel weights
            hinge.weightsLeft = W(sdX<hinge.intersection,:);
            hinge.weightsRight = W(sdX>hinge.intersection,:);
            
            % calculate value of criterion
            hinge.yHatLeft = (sdY(sdX<hinge.intersection) - affineX(sdX<hinge.intersection,:)*hinge.coeffLeft).^2;
            hinge.yHatRight = (sdY(sdX>hinge.intersection) - affineX(sdX>hinge.intersection,:)*hinge.coeffRight).^2;
            hinge.criterion = 0.5*sum([(hinge.weightsLeft).*hinge.yHatLeft; (hinge.weightsRight).*hinge.yHatRight]);
            
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
            ratio = 1;
            
            % initialize kernel
            W = exp((-1*abs(sdX-hinge.intersection).^2)/(2*h^2)); % determine Kernel weights
            hinge.weightsLeft = W(sdX<hinge.intersection,:);
            hinge.weightsRight = W(sdX>hinge.intersection,:);
            hinge.criterionMin = 0.5*sum((W).*(sdY-mean(sdY)).^2);
            
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
        ratio = 1;
        
        % initialize kernel
        W = exp((-1*abs(sdX-hinge.intersection).^2)/(2*h^2)); % determine Kernel weights
        hinge.weightsLeft = W(sdX<hinge.intersection,:);
        hinge.weightsRight = W(sdX>hinge.intersection,:);
        hinge.criterionMin = 0.5*sum((W).*(sdY-mean(sdY)).^2);
        
    else
        splitpoint = hinge.initial(1);
        break;
    end
    
    % reset to search new possible plit-point
%     if convergenceIterations == 2
%         hinge.splitpoint(reset+1) = splitpoint;
%         hinge.fitnesvalue(reset+1) = hinge.criterion/(10*sum(W));
% 
%         if reset < (size(hinge.initial,2)-1) % select a new starting point for local search
%             reset = reset+1;
% 
%             % reset
%             hinge.coeffLeft = zeros(2,1);
%             hinge.coeffRight = zeros(2,1);
%             lambda = lambdaStart;
%             convergenceIterations = 0;
%             hinge.intersection = hinge.initial(reset+1);
% 
%             % initialize kernel
%             W = exp((-1*abs(sdX-hinge.intersection).^2)/(2*h^2)); % determine Kernel weights
%             hinge.weightsLeft = W(sdX<hinge.intersection,:);
%             hinge.weightsRight = W(sdX>hinge.intersection,:);
%             hinge.criterionMin = 0.5*sum((W).*(sdY-mean(sdY)).^2);
%         end
%     end

end


%splitpoint = splitpoint*sqrt(varX)+meanX;
% [M, I] = min(hinge.fitnesvalue);
% if M < Inf
%     splitpoint = hinge.splitpoint(I)*sqrt(varX)+meanX;
%     splitpoint = hinge.splitpoint(1)*sqrt(varX)+meanX;
% else
%     splitpoint = hinge.initial(1)*sqrt(varX)+meanX;
% end
splitpoint = splitpoint*sqrt(varX)+meanX;

end

