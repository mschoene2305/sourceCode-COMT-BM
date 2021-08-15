function [BitMaskMatrix] = GenerateBitMaskMatrix(VarProperties)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here
    i1 = 1:(2^(size(VarProperties,2)-1)-1);
    a = [];

    for j = 1:size(VarProperties,2)
        a = [bitget(i1,j)',a];
    end
    
    BitMaskMatrix = a;
end

