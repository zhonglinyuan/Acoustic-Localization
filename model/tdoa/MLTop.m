%function [ result ] = MLTop()
% get raw data
if ~exist('MLTopSkip','var') || MLTopSkip == 0
    rawData = getDataVersionC();
    
    disp('done getting raw data');
    
    % 60% training 20% validation 20% testi
    %trainData = rawData([1 2 3 6 7 8 10],:);
    trainData = rawData;%rawData(1:(size(rawData,1) - 10),:);
    testData = rawData;%rawData((size(rawData,1) - 9):(size(rawData,1) - 0),:);
    disp('done generating train/vali/test set');
    
    % permute all data
    [permutedDataTrain permutedYRealTrain ]= getAllCombinationsVersionC(trainData);
    [permutedDataTest permutedYRealTest ]= getAllCombinationsVersionC(testData);
    disp('done permuting all data');
    
    % generate feature
    designMatrixTrain = generate_features_verA(permutedDataTrain);
    disp('done generating features for training set');
    designMatrixTest = designMatrixTrain;%generate_features_verA(permutedDataTest);
    disp('done generating features');
    
    MLTopSkip = 1;
end
% compare with ondevice-testing
%diffBetweenDeviceAndMatlab = sum(~((designMatrixTrain(:,1) - designMatrixTrain(:,2))<0) == permutedYDetectedTrain);
%fprintf('difference between device detection and simulated detection(this should be 0):%f(%d out of %d differnt)\n',diffBetweenDeviceAndMatlab/length(permutedYDetectedTrain),diffBetweenDeviceAndMatlab,length(permutedYDetectedTrain));

% straight cross correlation result
designMatrixAll= [designMatrixTrain;designMatrixTest];
permutedYRealAll = [permutedYRealTrain;permutedYRealTest];
crosscorrsuccess = sum(( ( (designMatrixAll(:,3) - designMatrixAll(:,5))<0 ) == permutedYRealAll));
crosscorrsuccesstest = sum(( ( (designMatrixTest(:,3) - designMatrixTest(:,5))<0 ) == permutedYRealTest));

fprintf('if you jsut use xcorr, success rate is: %f(on test set is %f)\n',crosscorrsuccess/length(permutedYRealAll),crosscorrsuccesstest/length(permutedYRealTest));

permutedYRealTrainNN = [permutedYRealTrain == 0 permutedYRealTrain == 1];
permutedYRealTestNN = [permutedYRealTest == 0 permutedYRealTest == 1];

NNtrain

% evaluate the network on unseen setups
outputs = net(designMatrixTest')';
output = (outputs(:,1) > 0.5);
output = ~output;
correctNNtest = sum(output == permutedYRealTest) / length(permutedYRealTest);
fprintf('classification rate with NN on test set:%f\n',correctNNtest);
%end

valid = (designMatrixAll(:,1) > 0.9) & (designMatrixAll(:,2) > 0.9);
sum(valid)
avg1 = (designMatrixAll(:,3) +  designMatrixAll(:,4))/2;
avg2 = (designMatrixAll(:,5) +  designMatrixAll(:,6))/2;
predicted = avg1 - avg2 < 0;
difference = predicted ~= permutedYRealAll;
difference = difference & valid;
fprintf('error rate:%f\n',sum(difference)/sum(valid));