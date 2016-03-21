function [] = analysis_template_accuracy_vs_templatenum(template1, template2, wheretoplot)

    percentage_used_as_template = 0.5;

    [template1_numrows template1_numcols] = size(template1);
    [template2_numrows template2_numcols] = size(template2);
    
    if (template1_numrows<=0 || template1_numcols<=0 || template2_numrows<=0 || template2_numcols<=0)
        return
    end
    
    
    if (template1_numcols < template2_numcols)
        template2 = template2(:,1:template1_numcols);
        template2_numcols = template1_numcols;
    elseif (template1_numcols > template2_numcols)
        template1 = template1(:,1:template2_numcols);
        template1_numcols = template2_numcols;
    end
    
    
    totalNumberOfRecordings = template1_numcols;
    
    totalNumberOfTemplates = floor(totalNumberOfRecordings*percentage_used_as_template);
    totalNumberOfTestCases = floor(totalNumberOfRecordings*(1-percentage_used_as_template));
    
    L1T = template1(:,1:totalNumberOfTemplates);
    L1test = template1(:, (totalNumberOfTemplates+1):(totalNumberOfTemplates+totalNumberOfTestCases));
    L2T = template2(:,1:totalNumberOfTemplates);
    L2test = template2(:, (totalNumberOfTemplates+1):(totalNumberOfTemplates+totalNumberOfTestCases));

    %L1T, L2T, L1test, L2test;
    
    
    L1T_L1test = ones(totalNumberOfTemplates, totalNumberOfTestCases);
    L2T_L1test = ones(totalNumberOfTemplates, totalNumberOfTestCases);
    
    L1T_L2test = ones(totalNumberOfTemplates, totalNumberOfTestCases);
    L2T_L2test = ones(totalNumberOfTemplates, totalNumberOfTestCases);
    
    %for numberOfTeamplates used
    for numberOfTemplatesUsed = 1:totalNumberOfTemplates
        %for eachTestCase
        for testCaseIndex = 1:totalNumberOfTestCases
            %for xcorr with the necessary number of templates

            total_L1T_x_L1test_value = 0;
            total_L2T_x_L1test_value = 0;
            total_L1T_x_L2test_value = 0;
            total_L2T_x_L2test_value = 0;
            
            for templateIndex = 1:numberOfTemplatesUsed
                %L1T x L1test
                L1T_x_L1test = max(xcorr(L1T(:,templateIndex), L1test(:,testCaseIndex), 'coeff'));
                %L2T x L1test
                L2T_x_L1test = max(xcorr(L2T(:,templateIndex), L1test(:,testCaseIndex), 'coeff'));
                
                
                %L1T x L2test
                L1T_x_L2test = max(xcorr(L1T(:,templateIndex), L2test(:,testCaseIndex), 'coeff'));
                %L2T x L2test
                L2T_x_L2test = max(xcorr(L2T(:,templateIndex), L2test(:,testCaseIndex), 'coeff'));
                
                total_L1T_x_L1test_value = total_L1T_x_L1test_value + L1T_x_L1test;
                total_L2T_x_L1test_value = total_L2T_x_L1test_value + L2T_x_L1test;
                total_L1T_x_L2test_value = total_L1T_x_L2test_value + L1T_x_L2test;
                total_L2T_x_L2test_value = total_L2T_x_L2test_value + L2T_x_L2test;
                
            end
            L1T_L1test(numberOfTemplatesUsed, testCaseIndex) = total_L1T_x_L1test_value/numberOfTemplatesUsed;
            L2T_L1test(numberOfTemplatesUsed, testCaseIndex) = total_L2T_x_L1test_value/numberOfTemplatesUsed;
            L1T_L2test(numberOfTemplatesUsed, testCaseIndex) = total_L1T_x_L2test_value/numberOfTemplatesUsed;
            L2T_L2test(numberOfTemplatesUsed, testCaseIndex) = total_L2T_x_L2test_value/numberOfTemplatesUsed;
        end
        
    end
    
    
    L1_found_correct_mat=L1T_L1test > L2T_L1test;
    L2_found_correct_mat=L2T_L2test > L1T_L2test;
    
    rate_of_L1_found_correct = sum(L1_found_correct_mat, 2)/totalNumberOfTestCases;
    rate_of_L2_found_correct = sum(L2_found_correct_mat, 2)/totalNumberOfTestCases;
    
    total_rate = (rate_of_L1_found_correct + rate_of_L2_found_correct)/2;
    
    subplot(wheretoplot);
    plot(total_rate,'bo');
    
    %hold on;
    %plot(rate_of_L2_found_correct,'rx');
    title('analysis_template_accuracy_vs_templatenum');
    %legend('rate correct vs # of templates','rate of L2 found correct vs # of templates');

end