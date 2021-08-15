function [NoteTerminal,predictors,response,alpha,beta] = PreprocessDataPLST(sample_t,ModeX,Nmin,Eta,Theta)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%-EINGANGSGRÖßEN-----------------------------------------------------------
% sample_t:     Trainingsdaten, die in den Knoten t fallen | Dim: N x M+1
% ModeX:        Eigenschaften der Eingangsgrößen; numerisch > 1;
%               kategorisch == 0; nicht relevant == -1; | Dim: 1 x M
% Nmin:         minimale Anzahl an Datensätzen, ab der terminiert wird
% Eta:
% Theta:
%-AUSGANGSGRÖßEN-----------------------------------------------------------
% NoteTerminal:     Abbruchbedingung für Terminieren eingetreten
% ComponentsPLS:    numerische Eingangsgrößen, die zur Transformation
%                   verwendet wurden
% predictors:       Eingangsgrößen (1. Elem. numerisch, rest kategorisch),
%                   anhand derer ein Split durchgeführt werden soll
% alpha:            Mittelwert der response-values (im Falle von CART
%                   lokales Modell)
M = size(ModeX,2);
N = size(sample_t,1);
predictors = sample_t(:,2:end);
response = sample_t(:,1);
alpha = zeros(1,M);
beta = [mean(response) zeros(1,M)];

%% Überprüfung, ob und welche der Ein- und Ausgangsgrößen keine Varianz aufweisen
NoteTerminal = 1;
if min(response) ~= max(response) % wenn die Ausgangsgrößen alle die gleiche Ausprägung haben, brauch nicht mehr geteilt werden
    for i=2:M
        if min(predictors(:,i)) ~= max(predictors(:,i))
            NoteTerminal = 0;

        else
            ModeX(i) = -1; % die numerische Variable besitzt 0 Varianz und wird folglich nicht zum Spliten genommen
        end
    end
end

%% Verdichtung der numerischen Eingangsgrößen zu einer Linearkombination und Schätzung eines uni-/multivariaten LS-Modells
if NoteTerminal == 0
    preVarX = var(predictors(:,ModeX >= 1));
    preVarY = var(response);
    meanX = mean(predictors(:,ModeX >= 1));
    meanY = beta(1);
    X = (predictors(:,ModeX >= 1) - meanX)./sqrt(preVarX);
    Y = (response - meanY)/sqrt(preVarY);

    % Reduktion der Eingangsgrößen durch überprüfung der covarianz
    covXY = abs(X'*Y);
    covXX = abs(X'*X);
    [covDescend,elementsPLS] = sort((covXY/norm(covXY)),'descend');

    for i=1:Eta 
        if norm(covDescend(1:i)) > Theta 
            % wenn die Vektorenlänge der i geordneten Einzelkomponenten den 
            % Hyperparameter Theta überschreitet, ist ein Abbruchkriterium
            % erreicht
            break;
        end
    end
    ComponentsPLS = elementsPLS(1:i);
    % Zuweisung der ausgewählten Eingangsgrößen für Transformation 
    X_rest = X(:,ComponentsPLS);

    % Decodierung, welche Predictors aus dem Basisdatensatz gewählt wurden
    %ModeX(~ismember(ModeX,ComponentsPLS) & ModeX > 0) = -1;
    % wird vorerst nicht gebraucht

    % wenn mit einer Größte bereits ein Großteil von Y abgebildet werden kann,
    % wird die else-verzweigung gewählt und es wird ein univariates Kriterium
    % bestimmt
    if i>1
        % PLS
        % ----ÄNDERUNG-AUF-OLS-10.04.2020
        w = X_rest'*Y;
       % w = inv((X_rest'*X_rest))*X_rest'*response; %OLS
        z = X_rest * w; % Bestimmung der ersten HK
        %q = 1; %OLS
    %    p = (X_rest'*z)/(z'*z); % Bestimmung der Regressionskoeffizienten zur Abbildung von X
        q = (Y'*z)/(z'*z); % Bestimmung der Regressionskoeffizienten zur Abbildung von Y
        % ----ÄNDERUNG-AUF-OLS-10.04.2020
        % Rücktransformation der Normalisierung für Modellausgang
        beta(ComponentsPLS+1) = (w'*q*sqrt(preVarY))./sqrt(preVarX(ComponentsPLS));
        beta(1) = meanY - sqrt(preVarY)*q*sum((w'.*meanX(ComponentsPLS))./sqrt(preVarX(ComponentsPLS)));
        
        % finale Überprüfung, ob der Knoten geteilt werden soll oder das
        % PLS-Modell als lokales Modell gültig wird
        if N > Nmin
            alpha(ComponentsPLS) = w'./sqrt(preVarX(ComponentsPLS));
            z = (z+sum((w'.*meanX(ComponentsPLS))./sqrt(preVarX(ComponentsPLS))))/max(abs(alpha)); % Normierung auf alpha(1)
            alpha = alpha/max(abs(alpha)); % Normierung auf alpha(1)
            predictors = [z predictors(:,ModeX == 0)];
        else
            NoteTerminal = 1;
        end
        
    else
        % Regressoren für OLS mit einer Eingangsgröße
        OLSR = [ones(N,1) predictors(:,ComponentsPLS(1))];
        beta([1 ComponentsPLS(1)+1]) = inv((OLSR'*OLSR))*OLSR'*response;
       
        % finale Überprüfung, ob der Knoten geteilt werden soll oder das
        % OLS-Modell als lokales Modell gültig wird
        if N > Nmin
            alpha(ComponentsPLS(1)) = 1;
            predictors = [predictors(:,ComponentsPLS(1)) predictors(:,ModeX == 0)];
        else
            NoteTerminal = 1;
        end    
    end
%     Y_rest = Y - X_rest*beta;
%     if (1 - (sum(var(Y_rest)./var(Y))/size(Y,2))) > Psi
%         % Hier kann zukünftig ein Abbruchkriterium rein, das greift, wenn
%         % die Varianz in Y mit der ersten HK um weniger als Psi % reduziert
%         % wurde
%         % Hier muss noch erweitert und überlegt werden: wenn eingewisser teil
%         % an Varianz nicht abgebildet werden kann aber man beweisen kann, dass
%         % das ganze eine stochastische Abweichung in Form von Rauschen ist, ist
%         % das Modell Final
%     end
end
end



