buffer1 = 1;
OneSE = 0;

for i=2:dimTK
    TK{3,(i-1)} = 0;
    for i2=1:N % ganze Prozedur für N Bäume durchlaufen
        buffer = DetermineError(Tn{i,i2},Dcv{1,i2},ModeX,Cij);
        TK{3,(i-1)} = TK{3,(i-1)} + (size(Dcv{1,i2},1)/size(Dtest,1))*buffer;
    end 
    
    if i==2
       Tmin = TK{1,i-1};
       AlphaMin = TK{3,i-1};
       buffer1 = TK{3,i-1};
    elseif TK{3,i-1} <= buffer1+E_Delta;
        Tmin = TK{1,i-1};
        AlphaMin = TK{3,i-1};
        buffer1 = TK{3,i-1};
    end
end 


if Enable1SE 
    OneSE = sqrt((AlphaMin*(1-AlphaMin))/size(Dtest,1));
    
    for i=2:dimTK
        if TK{3,i-1} <= (AlphaMin+OneSE)
            Tmin = TK{1,i-1};
        end
    end 
end
    
    