% Es wird immer der zuvor gestutzte Baum von T{1,n} zum Stutzen eines
% festen Alpha-Wertes verwendet
AlphaMean = zeros(1,(dimTK-1));


%% Berechnen der zugehörigen Alpha-Werte
for i=1:(dimTK-1)
    AlphaMean(i) = sqrt(TK{2,i}*TK{2,(i+1)}); 
end

%% Stutzen der N Bäume mit festem Alpha-Wert
buffer = {};
for i=1:(dimTK-1)
    parfor i2=1:N % ganze Prozedur für N Bäume durchlaufen
        buffer{1,i2} = PruningFixedAlpha(Tn{1,i2},Tn{i,i2},AlphaMean(i));% Funktion zum Stutzen durch AlphaMean(i2)
    end
    Tn((i+1),:) = buffer;
end 
    

