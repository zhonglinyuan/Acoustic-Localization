function [ predicted_location ] = template_addition_xcorrShift( template1, template2, test_data,dummyax )

persistent finaltmp1;
persistent finaltmp2;
if nargin == 2
    [m1 n1] = size(template1);
    [m2 n2] = size(template2);
    
    corr_matrix1 = zeros(n1);
    corr_matrix2 = zeros(n2);
    
    lags_matrix1 = zeros(n1);
    lags_matrix2 = zeros(n2);
    newtmp1 = zeros(size(template1));
    newtmp2 = zeros(size(template2));
    
    for i=1:n1
        for j=i+1:n1
            tmpXcorr = xcorr(template1(:,i),template1(:,j),'coeff');
            [tmpMax tmpInd] = max(tmpXcorr);
            corr_matrix1(i,j) = tmpMax;
            lags_matrix1(i,j) = tmpInd;
        end
    end
    
    
    for i=1:n2
        for j=i+1:n2
            tmpXcorr = xcorr(template2(:,i),template2(:,j),'coeff');
            [tmpMax tmpInd] = max(tmpXcorr);
            corr_matrix2(i,j) = tmpMax;
            lags_matrix2(i,j) = tmpInd;
        end
    end
    
    %finding the largest element in matrix
    biggest1 = 0;
    biggest2 = 0;
    
    i1 = 0;
    i2 = 0;
    
    for i=1:n1
        for j=i+1:n1
            if (corr_matrix1(i,j) > biggest1)
                biggest1 = corr_matrix1(i,j);
                i1 = i;
            end
        end
    end
    
    for i=1:n2
        for j=i+1:n2
            if(corr_matrix2(i,j) > biggest2)
                biggest2 = corr_matrix2(i,j);
                i2 = i;
            end
        end
    end
    
    %do time shift now for every template
    
    for i=1:n1
        if (i ~= i1)
            newtmp1(:,i) = align_using_xcorr(template1(:,i1),template1(:,i));
        else
            newtmp1(:,i) = template1(:,i);
        end
        newtmp1(:,i) = (newtmp1(:,i) - mean(newtmp1(:,i)))/std(newtmp1(:,i));
    end
    
    for i=1:n2
        if (i ~= i2)
            newtmp2(:,i) = align_using_xcorr(template2(:,i2),template2(:,i));
        else
            newtmp2(:,i) = template2(:,i);
        end
            newtmp2(:,i) = (newtmp2(:,i) - mean(newtmp2(:,i)))/std(newtmp2(:,i));

    end
    
    finaltmp1 = zeros(size(newtmp1,1),1);
    finaltmp2 = zeros(size(newtmp2,1),1);
    for i = 1:size(newtmp1,2)
        finaltmp1 = finaltmp1 + newtmp1(:,i);
    end
    for i = 1:size(newtmp2,2)
        finaltmp2 = finaltmp2 + newtmp2(:,i);
    end

    return
end

predicted_location = model_xcorr_avg(finaltmp1,finaltmp2,test_data,dummyax);

end

