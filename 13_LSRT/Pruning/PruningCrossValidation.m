function [TK,Tmin] = PruningCrossValidation(T,Dtest,ModeX,N,dimClass,DeltaPriorsBase,Cij,MinNodesize,Enable1SE)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% Ablauf bei der kreuzvalidierung:
% 1) Erzeugung eines vollst�ndig entwickelten Baumes und Stutzen durch WLP
% 2) Erzeugung von N CV-B�umen und Stutzen mittels fester Alpha-Werte
% 3) Validierung der N B�ume mit den nicht zur Erzeugung genutzten Samples
%    f�r alle errechneten Alpha-Werte
%
%    zur Errechnung der Alpha-Werte gilt Alpha = sqrt(Alpha_k*Alpha_k+1),
%    weil die auf Dtest basierenden B�ume zwischen Alpha_k und Alpha_k+1 
%    g�ltig sind 
%
%


%%
D_Tn = cell(1,N);
PrepareNDatasets;

%% Funktion zur Erzeugung des Hauptbaumes, dessen Generailisierung anschlie�end durch Kreuzvalidierung �berpr�ft wird
PrepareMergeMainTrees;

%% Erzeugung N ungestutzter B�ume auf Basis von D_Tn
Tn = cell(1,N);
parfor i=1:N
   Tn{1,i} = CARTfunction(Cij,MinNodesize,ModeX,0,0,D_Tn{1,i}); 
end
%Cij, Nmin, ModeX, is, EnableMulti, train
%% Stutzen der N B�ume mit festen, durch den Hauptbaum vorgegebene Alpha-Werte
PrunNTrees;

%% Sch�tzen des Generalisierungsfehlers f�r alle TK
DetermineGeneralisationError;



