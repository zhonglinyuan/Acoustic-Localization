% simulator
% this simulator will take data from 'data/matlab_collection' and simulator using all models available

addpath('../lib');
addpath('../model_xcorr_baseline');
addpath('../model_xcorr_avg');
addpath('../model_xcorr_avg_onset');
addpath('../model_xcorr_avg_subsampling');
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

path = '../../data/matlab_collection_multiple';

NUMTEMPLATE = 5;


performance = [];
performance_name = {};
filenames = dir(strcat(path,'/*.mat'));
disp(sprintf('INFO: found simulation data:%s\n',filenames.name));
for file_i = 1:size(filenames,1)
    fileName = filenames(file_i).name;
    fileName = strcat(path,'/',fileName);
    
    % get matrix
    load(fileName);
    disp(sprintf('------%s------',fileName));
    modelCount = 1;
    
    for num_loc = 8:8%size(loc,3)

        loc_use = loc(:,:,1:num_loc);
        size(loc_use)
        
        for num_tmplate = 1:NUMTEMPLATE
            % split into  template and test data
            if size(loc_use,2) <= NUMTEMPLATE
                disp(sprintf('INFO: %s does not have enough template, skip this setup',locDir));
                continue;
            end
            
            template = loc_use(:,1:num_tmplate,:);
            testing = loc_use(:,num_tmplate+1:end,:);
            
            % cycle through model to make prediciton
            
            % model_xcorr_avg
            totalcorrect = 0;
            totalnum = 0;
            for testclass = 1:size(testing,3)
                for testentry = 1:size(testing,2)
                    modeloutput = model_xcorr_avg(template,ones(size(template,3)*num_tmplate,1),testing(:,testentry,testclass),dummyax);
                    totalcorrect = totalcorrect + (modeloutput == testclass);
                    totalnum = totalnum + 1;
                end
            end
            disp(sprintf('performance(model_xcorr_avg template=%d, num_loc=%d):%f',num_tmplate,num_loc,totalcorrect/totalnum));
            performance(file_i,modelCount) = totalcorrect/totalnum;
            performance_name{modelCount} = sprintf('model_xcorr_avg num_template = %d num_loc=%d(blame keith)',num_tmplate,num_loc);
            modelCount = modelCount + 1;
            
            
            % model_xcorr_avg_onset
            totalcorrect = 0;
            totalnum = 0;
            model_xcorr_avg_onset(template);
            
            for testclass = 1:size(testing,3)
                for testentry = 1:size(testing,2)
                    modeloutput = model_xcorr_avg_onset(template,ones(size(template,3)*num_tmplate,1),testing(:,testentry,testclass),dummyax);
                    totalcorrect = totalcorrect + (modeloutput == testclass);
                    totalnum = totalnum + 1;
                end
            end
            disp(sprintf('performance(model_xcorr_avg_onset template=%d,num_loc=%d):%f',num_tmplate,num_loc,totalcorrect/totalnum));
            performance(file_i,modelCount) = totalcorrect/totalnum;
            performance_name{modelCount} = sprintf('model_xcorr_avg_onset num_template=%d,num_loc=%d(blame keith)',num_tmplate,num_loc);
            modelCount = modelCount + 1;
            
            % model_xcorr_avg_subsampling
            totalcorrect = 0;
            totalnum = 0;
            model_xcorr_avg_subsampling(template);
            
            for testclass = 1:size(testing,3)
                for testentry = 1:size(testing,2)
                    modeloutput = model_xcorr_avg_subsampling(template,ones(size(template,3)*num_tmplate,1),testing(:,testentry,testclass),dummyax);
                    totalcorrect = totalcorrect + (modeloutput == testclass);
                    totalnum = totalnum + 1;
                end
            end
            disp(sprintf('performance(model_xcorr_avg_subsampling template=%d,num_loc=%d):%f',num_tmplate,num_loc,totalcorrect/totalnum));
            performance(file_i,modelCount) = totalcorrect/totalnum;
            performance_name{modelCount} = sprintf('model_xcorr_avg_subsampling num_template=%d,num_loc=%d(blame keith)',num_tmplate,num_loc);
            modelCount = modelCount + 1;
        end
    end
end
disp('------SUMMARY------');
disp('performance');
for i = 1:size(performance,2)
    disp(sprintf('%s %f',performance_name{i},geomean(performance(:,i))));
end
disp('------END------');
