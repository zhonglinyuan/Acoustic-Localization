function [result] = model_logistic_regression(loc1,loc2,test)

persistent weight;
    
    if nargin == 2
        designMatrixTrain = model_logistic_regression_feature_extraction(loc1,loc2,loc1);
        designMatrixTrain = [designMatrixTrain; model_logistic_regression_feature_extraction(loc1,loc2,loc2)];


        actualY = [zeros(size(loc1,2),1);ones(size(loc1,2),1)];

        weight = glmfit(designMatrixTrain,actualY ,'binomial','logit');	
        return;
    end


yfitloc = glmval(weight, model_logistic_regression_feature_extraction(loc1,loc2,test),'logit');
result = (yfitloc > 0.5) + 1;

end

function [designMatrix] = model_logistic_regression_feature_extraction(loc1,loc2,test)
addpath('../lib');

desginMatrix = [];
for i=1:size(test,2)
    designMatrix(i,1) = mean(xcorr_all_vec(loc1,test(:,i)));
    designMatrix(i,2) = mean(xcorr_all_vec(loc2,test(:,i)));
end
end