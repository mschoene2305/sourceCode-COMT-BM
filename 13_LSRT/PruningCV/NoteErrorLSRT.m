function [error] = NoteErrorLSRT(Info,SampleNr)
%NOTEERROR Summary of this function goes here
%   Detailed explanation goes here
error = Info(1)*SampleNr;
end

