% train tree
ModeX = [1:size(dataTrain,2)-1];
[SubPLSTrees, PLST] = PrunedPLSTree(20, 1, size(dataTrain,2)-1, "AIC", 10, ModeX,...
    [dataTrain(:,end) dataTrain(:,1:end-1)], 'CART',"PLS2");

% determine test-error
ErrorOwnTreeMulti = determineSquaredTestErrorPLST(PLST, [dataTest(:,end), dataTest(:,1:end-1)], ModeX)


% visualize tree-behavior
figure();
PlotSurface(5,0,0,M,range,space,offset,[],1)
hold on;
PlotSurface(4,PLST,ModeX,M,range,3*space,offset,[],2)
hold off;