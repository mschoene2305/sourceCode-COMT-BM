%% Variablendeklaration
A_priori = zeros(1,dimClass); 
A_posteriori = A_priori;
SizeData_Nminus1 = 0;
dimDataset = size(Dtest,1);
Drest = Dtest;
buffer = Dtest;
Dcv = cell(1,N);
diffPriors = 0;
CounterDeltaPriors = 0;
DeltaPriors = 0;


%% Erzeugung der Größe der N Datensätze
SizeData_Nminus1 = round(dimDataset/N);
% SizeData_N = dimDataset - (N-1)*SizeData_Nminus1;

%% Bestimmung der A-priori-Wahscheinlichkeit des Datensatzes Dtest
for i = 1:dimDataset %Bestimmen der A-Priori-Wahrscheinlichkeit des Datensatzes und Transormation cj von {1,2,3} auf {0,1,2}
    for i2=0:(dimClass-1)
        if Dtest(i,1) == i2
            A_priori(i2+1) = A_priori(i2+1)+1;
        end
    end
end

A_priori = A_priori/dimDataset;

%% Erzeugung der N Datensätze
for i=1:(N-1)
    
    ProbabilityNotEqual = 1;
    CounterDeltaPriors = 0;
    DeltaPriors = DeltaPriorsBase;
    
    %% Datensätze so lange separieren, bis Teil-Datensatz der CV gleiche Verteilung wie A-prio hat
    while ProbabilityNotEqual 
        
        % Variablen rücksetzen
        buffer = Drest;
        Dcv{1,i} = [];
        A_posteriori = zeros(1,dimClass);

        %% Auswahl zufälliger N Samples aus Data
        for i2 = 1:SizeData_Nminus1 

            RandNr = randi([1 size(buffer,1)],1,1); %Erzeugung Zufallszahl
            Dcv{1,i} = [Dcv{1,i}; buffer(RandNr,:)]; %Erweiterung trainingsdtaen mit ausgewähltem Trainingssample
            buffer2 = buffer(RandNr,:);
            buffer(RandNr,:) = []; %Reduzierung der Testmenge um ausgewählten Trainingssample
            
            %% Bestimmung A-posteriori
            for i3=0:(dimClass-1)
                if buffer2(1,1) == i3
                    A_posteriori(i3+1) = A_posteriori(i3+1)+1;
                end
            end
        end

        A_posteriori = A_posteriori/SizeData_Nminus1;
        diffPriors = 0;
        
        %% Differenzbildung ziwschen Posteriori und Preori
        for i2=1:dimClass
            diffPriors = diffPriors + abs(A_priori(i2)-A_posteriori(i2));
        end
        
        %% Anhebung des Schwellwertes, wenn nach 30 Durchläufen kein passender Datensatz gezogen wurde
        if CounterDeltaPriors > 30
            DeltaPriors = DeltaPriors + 0.5*DeltaPriorsBase;
            CounterDeltaPriors = 0;
        end

        %% Abfrage Differenzbildung
        if diffPriors < DeltaPriors % ((deltaPriors/2) + ((i/N)*(DeltaPriors/2))) 
            ProbabilityNotEqual = 0;
           
        else
            CounterDeltaPriors = CounterDeltaPriors + 1;
        end
    end  
    
    Drest = buffer;
    
end

Dcv{1,N} = Drest;

%% Erzeugung der Trainingsdatensätze der einzelnen Bäume - jeder Datensatz beinhaltet N-1 Teile von Dcv
% D_Tn{1,1} = {Dcv{1,2}, Dcv{1,3},..., Dcv{1,N}}
% D_Tn{1,2} = {Dcv{1,1}, Dcv{1,3},..., Dcv{1,N}}
% ...
% D_Tn{1,N} = {Dcv{1,1}, Dcv{1,2},..., Dcv{1,N-1}}
for i=1:N
   for i2=1:N
       if i2 ~= i
           D_Tn{1,i2} = [D_Tn{1,i2}; Dcv{1,i}];
       end
   end
end

