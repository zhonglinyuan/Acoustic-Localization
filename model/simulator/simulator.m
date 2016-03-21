% simulator
% this simulator will take data from 'data/matlab_collection' and simulator using all models available

addpath('../lib');
addpath('../model_xcorr_baseline');
addpath('../model_xcorr_avg');
addpath('../model_xcorr_avg_onset');
addpath('../model_gcc_avg');
addpath('../model_lpc');
addpath('../model_xcorr_max');
addpath('../model_xcorr_knn');
addpath('../model_xcorr_avg_dynamic_template_selection');
addpath('../model_logistic_regression');
addpath('../model_xcorr_select_variations');
addpath('../model_xcorr_weighted_sum_difference');
addpath('../model_xcorr_template_addition');

dummyfg = figure();
dummyax = subplot(1,1,1);

% go through all directorys in matlab_collection, and for each data set,
% get loc1 loc2 test data and call models

path = '../../data/matlab_collection';

NUMTEMPLATE = 3;


performance = [];
performance_name = {};
filenames = dir(strcat(path,'/*.mat'));
disp(sprintf('INFO: found simulation data:%s\n',filenames.name));
for file_i = 1:size(filenames,1)
    fileName = filenames(file_i).name;
    fileName = strcat(path,'/',fileName);
    
    % get matrix
    load(fileName);
    disp(sprintf('------%s------(%d loc1, %d loc2)',fileName,size(loc1,2),size(loc2,2)));
    
    % split into  template and test data
    if size(loc1,2) <= NUMTEMPLATE || size(loc2,2) <= NUMTEMPLATE
        disp(sprintf('INFO: %s does not have enough template, skip this setup',locDir));
        continue;
    end
    
    loc1Template = loc1(:,1:NUMTEMPLATE);
    loc2Template = loc2(:,1:NUMTEMPLATE);
    locT = loc1Template;
    locT(:,:,2) = loc2Template;
    locTnum = [NUMTEMPLATE;NUMTEMPLATE];
    loc1Test = loc1(:,(NUMTEMPLATE+1):end);
    loc2Test = loc2(:,(NUMTEMPLATE+1):end);
    
    modelCount = 1;
    
    % cycle through model to make prediciton
    realResult = [ones(1,size(loc1Test,2)),2*ones(1,size(loc2Test,2))];
    
    % model_cross_correlation_baseline
    predictedResult = [];
    for i = 1:size(loc1Test,2)
        predictedResult(i) = model_xcorr_baseline(loc1Template,loc2Template,loc1Test(:,i));
    end
    for i = 1:size(loc2Test,2)
        predictedResult(end+1) = model_xcorr_baseline(loc1Template,loc2Template,loc2Test(:,i));
    end
    disp(sprintf('performance(model_cross_correlation_baseline):%f',sum(predictedResult == realResult)/length(predictedResult)));
    performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    performance_name{modelCount} = 'model_cross_correlation_baseline(blame keith)';
    modelCount = modelCount + 1;
    
    % model_lpc
    %     predictedResult = [];
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = model_lpc(loc1Template(:,1),loc2Template(:,1),loc1Test(:,i));
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = model_lpc(loc1Template(:,1),loc2Template(:,1),loc2Test(:,i));
    %     end
    %     disp(sprintf('performance(model_lpc):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     performance_name{modelCount} = 'model_lpc(blame keith)';
    %     modelCount = modelCount + 1;
    %
    % model_xcorr_avg
    predictedResult = [];
    for i = 1:size(loc1Test,2)
        predictedResult(i) = model_xcorr_avg(locT,locTnum,loc1Test(:,i),dummyax);
    end
    for i = 1:size(loc2Test,2)
        predictedResult(end+1) = model_xcorr_avg(locT,locTnum,loc2Test(:,i),dummyax);
    end
    disp(sprintf('performance(model_xcorr_avg):%f',sum(predictedResult == realResult)/length(predictedResult)));
    performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    performance_name{modelCount} = sprintf('model_xcorr_avg(blame keith)');
    modelCount = modelCount + 1;
    
    % model_xcorr_avg_subsampling
    model_xcorr_avg_subsampling(locT);
    predictedResult = [];
    for i = 1:size(loc1Test,2)
        predictedResult(i) = model_xcorr_avg_subsampling(locT,locTnum,loc1Test(:,i),dummyax);
    end
    for i = 1:size(loc2Test,2)
        predictedResult(end+1) = model_xcorr_avg_subsampling(locT,locTnum,loc2Test(:,i),dummyax);
    end
    disp(sprintf('performance(model_xcorr_avg_subsampling:%f',sum(predictedResult == realResult)/length(predictedResult)));
    performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    performance_name{modelCount} = sprintf('model_xcorr_avg_subsampling (blame keith)');
    modelCount = modelCount + 1;
    % model_gcc_avg
    %     for k = 1:NUMTEMPLATE
    %         predictedResult = [];
    %         for i = 1:size(loc1Test,2)
    %             predictedResult(i) = model_gcc_avg(loc1Template(:,1:k),loc2Template(:,1:k),loc1Test(:,i),dummyax);
    %         end
    %         for i = 1:size(loc2Test,2)
    %             predictedResult(end+1) = model_gcc_avg(loc1Template(:,1:k),loc2Template(:,1:k),loc2Test(:,i),dummyax);
    %         end
    %         disp(sprintf('performance(model_gcc_avg with %d templates):%f',k,sum(predictedResult == realResult)/length(predictedResult)));
    %         performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %         performance_name{modelCount} = sprintf('model_gcc_avg with %d templates(blame keith)',k);
    %         modelCount = modelCount + 1;
    %     end
    % model_xcorr_knn
    %     for k = 1:2*NUMTEMPLATE
    %         predictedResult = [];
    %         for i = 1:size(loc1Test,2)
    %             predictedResult(i) = model_xcorr_knn(loc1Template,loc2Template,loc1Test(:,i),dummyax,k);
    %         end
    %         for i = 1:size(loc2Test,2)
    %             predictedResult(end+1) = model_xcorr_knn(loc1Template,loc2Template,loc2Test(:,i),dummyax,k);
    %         end
    %         disp(sprintf('performance(model_xcorr_knn with k= %d ):%f',k,sum(predictedResult == realResult)/length(predictedResult)));
    %         performance_name{modelCount} = sprintf('model_xcorr_knn with k= %d(blame keith)',k);
    %         performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %         modelCount = modelCount + 1;
    %     end
    %
    % model_xcorr_max
    %     predictedResult = [];
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = model_xcorr_max(loc1Template,loc2Template,loc1Test(:,i),dummyax);
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = model_xcorr_max(loc1Template,loc2Template,loc2Test(:,i),dummyax);
    %     end
    %     disp(sprintf('performance(model_xcorr_max):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('model_xcorr_max(blame keith)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    
    % model_xcorr_avg_onset
    %     predictedResult = [];
    %     model_xcorr_avg_onset(loc1Template,loc2Template);
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = model_xcorr_avg_onset(loc1Template,loc2Template,loc1Test(:,i),dummyax);
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = model_xcorr_avg_onset(loc1Template,loc2Template,loc2Test(:,i),dummyax);
    %     end
    %     disp(sprintf('performance(model_xcorr_avg_onset):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('model_xcorr_avg_onset(blame keith)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    
    % findVariations
    %     predictedResult = [];
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = findVariations(loc1Template,loc2Template,loc1Test(:,i));
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = findVariations(loc1Template,loc2Template,loc2Test(:,i));
    %     end
    %     disp(sprintf('performance(findVariations):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('findVariations(blame max)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    %
    %template addition using onset as time alignment
    %     predictedResult = [];
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = template_addition(loc1Template,loc2Template,loc1Test(:,i));
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = template_addition(loc1Template,loc2Template,loc2Test(:,i));
    %     end
    %     disp(sprintf('performance(model_xcorr_template_addition(using onset time alignment)):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('model_xcorr_template_addition1(blame max)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    
    %template addition using max xcorr index as time alignment
    %     predictedResult = [];
    %     template_addition_xcorrShift(loc1Template,loc2Template);
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = template_addition_xcorrShift(loc1Template,loc2Template,loc1Test(:,i),dummyax);
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = template_addition_xcorrShift(loc1Template,loc2Template,loc2Test(:,i),dummyax);
    %     end
    %     disp(sprintf('performance(model_xcorr_template_addition(using xcorr index time alignment)):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('model_xcorr_template_addition2(blame max)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    %
    
    % model_xcorr_weighted_sum_difference
    %    predictedResult = [];
    %    prediction_weighted_sum_difference(loc1Template,loc2Template);
    %    for i = 1:size(loc1Test,2)
    %        predictedResult(i) = prediction_weighted_sum_difference(loc1Template,loc2Template,loc1Test(:,i),NUMTEMPLATE,dummyax,dummyax,dummyax);
    %    end
    %    for i = 1:size(loc2Test,2)
    %        predictedResult(end+1) = prediction_weighted_sum_difference(loc1Template,loc2Template,loc2Test(:,i),NUMTEMPLATE,dummyax,dummyax,dummyax);
    %    end
    %    disp(sprintf('performance(model_xcorr_weighted_sum_difference):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %    performance_name{modelCount} = sprintf('model_xcorr_weighted_sum_difference(blame kevin)');
    %    performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %    modelCount = modelCount + 1;
    %
    
    % model_xcorr_avg_dynamic_template_selection
    %     model_xcorr_avg_dynamic_template_selection(loc1Template,loc2Template);
    %     predictedResult = [];
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = model_xcorr_avg_dynamic_template_selection(loc1Template,loc2Template,loc1Test(:,i),dummyax);
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = model_xcorr_avg_dynamic_template_selection(loc1Template,loc2Template,loc2Test(:,i),dummyax);
    %     end
    %     disp(sprintf('performance(model_xcorr_avg_dynamic_template_selection):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    
    
    % model_logistic_regression
    %model_xcorr_avg_dynamic_template_selection(loc1Template,loc2Template);
    %     predictedResult = [];
    %     warning('off','all');
    %     model_logistic_regression(loc1Template,loc2Template);
    %     for i = 1:size(loc1Test,2)
    %         predictedResult(i) = model_logistic_regression(loc1Template,loc2Template,loc1Test(:,i));
    %     end
    %     for i = 1:size(loc2Test,2)
    %         predictedResult(end+1) = model_logistic_regression(loc1Template,loc2Template,loc2Test(:,i));
    %     end
    %     disp(sprintf('performance(model_logistic_regression):%f',sum(predictedResult == realResult)/length(predictedResult)));
    %     performance_name{modelCount} = sprintf('model_logistic_regression(blame keith)');
    %     performance(file_i,modelCount) = sum(predictedResult == realResult)/length(predictedResult);
    %     modelCount = modelCount + 1;
    %     warning('on','all');
    
    
end
disp('------SUMMARY------');
disp('performance');
for i = 1:size(performance,2)
    disp(sprintf('%s %f',performance_name{i},geomean(performance(:,i))));
end
disp('------END------');
