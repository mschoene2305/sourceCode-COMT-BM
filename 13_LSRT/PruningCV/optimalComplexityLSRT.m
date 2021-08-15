function [indexSubtrees] = optimalComplexityLSRT(cvSubtrees,TestCV,ModeX,Enable1SE)
%OPTIMALCOMPLEXITY Summary of this function goes here
%   Detailed explanation goes here
dimCV = size(cvSubtrees,2);
Subtrees = cvSubtrees{1,1};
dimAlpha = size(Subtrees,2);
errorAlpha = zeros(dimAlpha,1);
sizeTestdata = zeros(size(TestCV,2),1);
for i=1:size(TestCV,2)
    sizeTestdata(i) = size(TestCV{1,i},1);
end

factor = 1/sum(sizeTestdata);

%% Schleife, die jeder Komplexität (durch Alpha defineirt) ein Fehlermaß zuweist
for i=1:dimAlpha
    %% Schleife, die aus allen CV-Testdatensätzen einen durchschnittlichen Vorhersagefehler bestimmt
    for i2=1:dimCV
        Subtrees = cvSubtrees{1,i2};
        currentTree = Subtrees{1,i};
        Testdata = TestCV{1,i2};
        %% Fehlerbestimmung innerhalb eines CV-Testdatensatzes und dem dazugehörogen Modell
        for i3=1:sizeTestdata(i2)
            y = PredictSampleLSRT(currentTree, Testdata(i3,2:end), ModeX);
            error = (Testdata(i3,1) - y)^2;
            errorAlpha(i) = errorAlpha(i) + factor*error;
        end        
    end    
end

%plot(errorAlpha);
%% Auswahl der Komplexität, aus der der geringste Fehler resultiert
indexSubtrees = 1;
minAlpha = errorAlpha(1);
for i=2:dimAlpha
    if errorAlpha(i) < minAlpha
        indexSubtrees = i;
        minAlpha = errorAlpha(i);
    end
end

if Enable1SE 
    dimTestdata = sum(sizeTestdata);
    error = [];
    factor = 0.5;
    for i2=1:dimCV
        Subtrees = cvSubtrees{1,i2};
        currentTree = Subtrees{1,indexSubtrees};
        Testdata = TestCV{1,i2};
        %% Fehlerbestimmung innerhalb eines CV-Testdatensatzes und dem dazugehörogen Modell
        for i3=1:sizeTestdata(i2)
            y = PredictSampleLSRT(currentTree, Testdata(i3,2:end), ModeX);
            error = [error; (Testdata(i3,1) - y)^2];
        end        
    end    
    OneSE = sqrt(var(error)/dimTestdata);
    
    for i=2:dimAlpha
        if errorAlpha(i) <= (minAlpha+(OneSE*factor))
            indexSubtrees = i;
        end
    end 
end
end

