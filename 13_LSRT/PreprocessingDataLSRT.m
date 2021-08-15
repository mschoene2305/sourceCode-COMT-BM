function [NoteTerminal,predictors,response,alpha,beta] = PreprocessingDataLSRT(sample_t,ModeX,Nmin,Eta,IC,splitModelType)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%-EINGANGSGR��EN-----------------------------------------------------------
% sample_t:     Trainingsdaten, die in den Knoten t fallen | Dim: N x M+1
% ModeX:        Eigenschaften der Eingangsgr��en; numerisch > 1;
%               kategorisch == 0; nicht relevant == -1; | Dim: 1 x M
% Nmin:         minimale Anzahl an Datens�tzen, ab der terminiert wird
% Eta:
% Theta:
%-AUSGANGSGR��EN-----------------------------------------------------------
% NoteTerminal:     Abbruchbedingung f�r Terminieren eingetreten
% ComponentsPLS:    numerische Eingangsgr��en, die zur Transformation
%                   verwendet wurden
% predictors:       Eingangsgr��en (1. Elem. numerisch, rest kategorisch),
%                   anhand derer ein Split durchgef�hrt werden soll
% alpha:            Mittelwert der response-values (im Falle von CART
%                   lokales Modell)
M = size(ModeX,2);
N = size(sample_t,1);
predictors = sample_t(:,2:end);
response = sample_t(:,1);
alpha = zeros(1,M);
beta = [mean(response) zeros(1,M)];

%% �berpr�fung, ob und welche der Ein- und Ausgangsgr��en keine Varianz aufweisen
NoteTerminal = 1;
if min(response) ~= max(response) % wenn die Ausgangsgr��en alle die gleiche Auspr�gung haben, brauch nicht mehr geteilt werden
    for i=1:M
        if min(predictors(:,i)) ~= max(predictors(:,i))
            NoteTerminal = 0;

        else
            ModeX(i) = -1; % die numerische Variable besitzt 0 Varianz und wird folglich nicht zum Spliten genommen
        end
    end
end

%% Verdichtung der numerischen Eingangsgr��en zu einer Linearkombination und Sch�tzung eines uni-/multivariaten LS-Modells
if NoteTerminal == 0
    
    % Bestimmung eines linearen Modells durch Vorw�rtsselektion
    if splitModelType == "LS" || splitModelType == "ls"
        [beta([true (ModeX > 0)]),coefficientsNormalized,z,dimensionZ] = ForwardSelectionLsNormalizedLSRT(response,predictors(:,ModeX > 0),IC,Eta);
    elseif splitModelType == "LSstd" || splitModelType == "lsstd"
        [beta([true (ModeX > 0)]),coefficientsNormalized,z,dimensionZ] = ForwardSelectionLsStandartLSRT(response,predictors(:,ModeX > 0),IC,Eta);
    elseif splitModelType == "PLS" || splitModelType == "pls"
        [coefficients,coefficientsNormalized,z,NoteTerminal,dimensionZ] = ForwardSelectionPLS_LSRT(response,predictors(:,ModeX > 0),IC,Eta);
        beta(1:dimensionZ,[true (ModeX > 0)]) = coefficients;
    elseif splitModelType == "PLS2" || splitModelType == "pls2"
        [coefficients,coefficientsNormalized,z,dimensionZ] = ForwardSelectionPLS2_LSRT(response,predictors(:,ModeX > 0),IC,Eta);
        beta(1:size(coefficients,1),[true (ModeX > 0)]) = coefficients;
    elseif splitModelType == "LS+" || splitModelType == "ls+"
        [beta([true (ModeX > 0)]),coefficientsNormalized,z,dimensionZ] = StepwiseSelectionLSRT(response,predictors(:,ModeX > 0),IC);
    elseif splitModelType == "CART" || splitModelType == "cart"
        z = predictors(:,ModeX > 0);
        dimensionZ = size(z,2);
        coefficientsNormalized = eye(dimensionZ);
    elseif splitModelType == "PHD" || splitModelType == "phd"
        [beta([true (ModeX > 0)]),coefficientsNormalized,z,dimensionZ] = PrincipalHesseDirectionsLSRT(response,predictors(:,ModeX > 0));
    end
    
    if N <= Nmin
        NoteTerminal = 1;
    elseif NoteTerminal == 0
        alpha(1:dimensionZ,ModeX > 0) = coefficientsNormalized;
        predictors = [z predictors(:,ModeX == 0)];
    end
end
end



