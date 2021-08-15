function [Tk_post] = Transformation(T,Tk_pre)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Tk_post = Tk_pre;
dimTree = size(Tk_pre,1);
NoteInfo = Tk_pre{1,1};

for i=1:dimTree
    NoteInfo = Tk_pre{i,1};
    Tk_post{i,3} = T{NoteInfo(1),3};
end

