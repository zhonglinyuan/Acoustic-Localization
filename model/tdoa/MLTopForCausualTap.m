% This file is create to evalute performance on data/20130204.tar.gz
% logic flow:
%   1. get raw data
%   2. permute raw data
%   3. get features
%   4. use cross correlation result to evaluate the data
if ~exist('MLTopForCausualTapSkip','var') || MLTopForCausualTapSkip == 0
    rawData = getDataVersionA();
    
    disp('done getting raw data');
    
    % 60% training 20% validation 20% testi
    trainData = rawData;%rawData([1 3 5 7 9 10 11 12],:);
    valiData = rawData([1 2],:);
    testData = rawData([1 2],:);
    disp('done generating train/vali/test set');
    
    % permute all data
    [permutedDataTrain permutedYRealTrain templateChanged]= getAllCombinations(trainData);
    [permutedDataVali permutedYRealVali]= getAllCombinations(valiData);
    [permutedDataTest permutedYRealTest]= getAllCombinations(testData);
    disp('done permuting all data');
    
    % generate feature
    designMatrixTrain = generate_features_verA(permutedDataTrain);
    disp('done generating features for training set');
    %designMatrixVali = generate_features_verA(permutedDataVali);
    designMatrixVali = designMatrixTrain;
    disp('done generating features for vali set');
   % designMatrixTest = generate_features_verA(permutedDataTest);
    designMatrixTest = designMatrixTrain;
    disp('done generating features');
    
    MLTopForCausualTapSkip = 1;
end

% use cross correlation to make predictions and check result
correctTrain = sum(((designMatrixTrain(:,1) - designMatrixTrain(:,2))<0) == permutedYRealTrain);
correctVali = sum(((designMatrixVali(:,1) - designMatrixVali(:,2))<0) == permutedYRealVali);
correctTest = sum(((designMatrixTest(:,1) - designMatrixTest(:,2))<0) == permutedYRealTest);
fprintf('cross correlation accuracy on training set:%f, validatoin set:%f, testing set:%f\n',correctTrain/length(permutedYRealTrain),correctVali/length(permutedYRealVali),correctTest/length(permutedYRealTest));

figure;
hold on
a = [];
for i = 1: templateChanged(end)
    tmp = (templateChanged == i);
    indexLast = find(tmp, 1, 'last');
    indexFirst = find(tmp, 1, 'first');
    cross=max(xcorr(permutedDataTrain{indexFirst,1}{7},permutedDataTrain{indexFirst,2}{7},'coeff'));
    designMatrix = designMatrixTrain(indexFirst:indexLast,:);
    yreal = permutedYRealTrain(indexFirst:indexLast,1);
    correct = sum(((designMatrix(:,1) - designMatrix(:,2))<0) == yreal);
    fprintf('cross correlation accuracy on training set:%f(location%d,%d,%d),%f\n',correct/length(yreal),i,indexFirst,indexLast,cross);
    plot (i,correct/length(yreal),'or',i,cross,'xg');
    a(i,1) = correct/length(yreal);
    a(i,2) = cross;
end
figure();
plot(a(:,1),a(:,2),'or');

designMatrixTrainTranspose = designMatrixTrain';
permutedYRealTrainTranspose = [permutedYRealTrain == 0 permutedYRealTrain == 1]';



