function [Vec,Val,ParaNorm] = rOPG_adj(X,y,d,J)
% author:       Marvin Schöne, Center for Applied Data Science Gütersloh,
%               University of Applied Sciences Bielefeld
% first draft:  08.07.2021


% lierature:   Sufficient Dimension Reduction Methods and Applications 
%              with R, Li 2018
%              An adaptive estimation of dimesnion reduction space, Xia et.
%              al.
%              A Constructive Approach to the Estimation of Dimension
%              Reduction Directions, Xia 2007

%% calculate data properties
[n, m] = size(X);
d_new = m;
c0 = 0.85; 
h = c0*(4/(3*n))^(1/5);
Vec = diag(ones(1,m));
VecPrevious = zeros(m,m);
convergenceIterations = 0;

%% standardize data
varX = var(X); varY = var(y); varX(varX==0)=0.00000001;
meanX = mean(X); meanY = mean(y);
sdX = (X - meanX)./sqrt(varX); sdY = (y - meanY)/sqrt(varY);

for j=1:J
    %% determine weights by gaussian kernel exp(-|X|^2/2*sigma^2)
    % diagonal elements of U each represent squared sum of the sample 
    % respectively (see p.162 of Li 2018)
    % reduce Kernel dimesnion from m to d
    rX = sdX*Vec;
    K = zeros(n,n);
    
    for i=1:n
        diff = rX - rX(i,:);
        if d_new > 1
            K(:,i) = exp(-1*((sum(abs(diff')))./d_new).^(2)./(2*(h^(2))))';
        else
            K(:,i) = exp(-1*((abs(diff'))./d_new).^(2)./(2*(h^(2))))';
        end
    end

    %% determine gradients in local regions
    affineX = [ones(n,1), sdX];
    B = zeros(m,n);

    for i=1:n
        % determine local linear approcimation of gradient bei WLS
        hessian = (affineX'*diag(K(:,i))*affineX);
        if min(eig(hessian)) > 0.0000000000001
            beta = hessian\affineX'*diag(K(:,i))*sdY;
            % ignore affine component
            B(:,i) = beta(2:end);
        end
    end
    % estimate OPG
    OPG = B*B';

    % determine eigenvectors and eigenvalues of OPG
    [Vec, Val] = eig(OPG);
    [~, I] = sort(diag(Val),'descend');
    
    % scale d in a way that at least 65% of the sum of eigenvalues are
    % included
    proofVal = diag(Val); proofVal = proofVal(I); sumVal = proofVal(1); d_new = d;
    for k=2:size(proofVal,1)
        if sumVal < (0.65*sum(proofVal))
            d_new = k;
            sumVal = sumVal + proofVal(k);
        else
            break;
        end 
    end

    % check convergence
    ratio = abs(Vec(:,I(1))./VecPrevious(:,1));
    if abs(1-mean(abs(mean(ratio)))) < 0.02
        if convergenceIterations == 0
            convergenceIterations = 1;
        else
            Vec = Vec(:,I(1:d_new));
            break; % if condition holds a secound time, convergence is reaced
        end
    else
        convergenceIterations = 0;
    end
    
    % stor previous eigenvectors
    VecPrevious = Vec(:,I);
    Vec = Vec(:,I(1:d_new));
    
end

Vec = diag(varX.^(-1/2))*Vec; % (already beta tilde)
Val = Val(:,I(1:d_new));

ParaNorm.X.var = varX;
ParaNorm.X.values = sdX;
ParaNorm.X.mean = meanX;
ParaNorm.y.var = varY;
ParaNorm.y.mean = meanY;


end

