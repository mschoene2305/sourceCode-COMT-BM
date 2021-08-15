function [TK,Tmin] = PruningCrossValidation(T,Dtest,ModeX,N,dimClass,DeltaPriorsBase,Cij,MinNodesize,Enable1SE)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Ablauf bei der kreuzvalidierung:
% 1) Erzeugung eines vollständig entwickelten Baumes und Stutzen durch WLP
% 2) Erzeugung von N CV-Bäumen und Stutzen mittels fester Alpha-Werte
% 3) Validierung der N Bäume mit den nicht zur Erzeugung genutzten Samples
%    für alle errechneten Alpha-Werte
%
%    zur Errechnung der Alpha-Werte gilt Alpha = sqrt(Alpha_k*Alpha_k+1),
%    weil die auf Dtest basierenden Bäume zwischen Alpha_k und Alpha_k+1 
%    gültig sind 
%
%


%%
D_Tn = cell(1,N);
PrepareNDatasets;

%% Funktion zur Erzeugung des Hauptbaumes, dessen Generailisierung anschließend durch Kreuzvalidierung überprüft wird
PrepareMergeMainTrees;

%% Erzeugung N ungestutzter Bäume auf Basis von D_Tn
Tn = cell(1,N);
parfor i=1:N
   Tn{1,i} = CARTfunction(Cij,MinNodesize,ModeX,0,0,D_Tn{1,i}); 
end
%Cij, Nmin, ModeX, is, EnableMulti, train
%% Stutzen der N Bäume mit festen, durch den Hauptbaum vorgegebene Alpha-Werte
PrunNTrees;

%% Schätzen des Generalisierungsfehlers für alle TK
DetermineGeneralisationError;



