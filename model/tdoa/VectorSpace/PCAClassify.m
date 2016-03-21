function [ location ] = PCAClassify( template1, template2, test_point, flag )
%flag = 0 means training + testing
%flag = 1 means just testing

persistent data_train;
persistent label_train;
persistent base;
threshold = 40;

number_to_truncate_to = 4000;
[m1 n1] = size(template1);
[m2 n2] = size(template2);

if (flag == 0)
%check if size match up if not choose the short one
    if (n1 ~= n2)
        if (n1 > n2)
            template1 = template1(:,1:n2);
            n1 = n2;
        else
            template2 = template2(:,1:n1);
            n2 = n1;
        end
    end

%find the onset index and truncate the vectors
    truncated1 = zeros(number_to_truncate_to + 1,n1);
    truncated2 = zeros(number_to_truncate_to + 1,n2);
    for i=1:n1
        idx1 = find(abs(template1(:,i))>threshold,1);
        idx2 = find(abs(template2(:,i))>threshold,1);
  %      truncated1(:,i) = template1(idx1:idx1+number_to_truncate_to,i);
  %      truncated2(:,i) = template2(idx2:idx2+number_to_truncate_to,i);
        truncated1(:,i) = findVec(idx1, number_to_truncate_to, template1);
        truncated2(:,i) = findVec(idx2, number_to_truncate_to, template2);
    end

%take absolute and normalize truncated vectors
    for j=1:n1
        %max1 = max(abs(truncated1(:,j)));
        %max2 = max(abs(truncated2(:,j)));

        %truncated1(:,j) = abs(truncated1(:,j))/max1;
        %truncated2(:,j) = abs(truncated2(:,j))/max2;
        
        truncated1(:,j) = abs(truncated1(:,j));
        truncated2(:,j) = abs(truncated2(:,j));
    end

%now do PCA analysis of data
    Dimension_to_reduce_to = 100;
    [base mean projX] = pcaimg([truncated1, truncated2],Dimension_to_reduce_to);
    data_train = projX;
    label_train = [zeros(1,n1), ones(1,n1); ones(1,n1), zeros(1,n1)];
end

truncated_test = zeros(number_to_truncate_to,1);
idxt = find(abs(test_point)>threshold,1);
%disp(size(idxt));
%truncated_test = test_point(idxt:idxt+number_to_truncate_to);
truncated_test = findVec(idxt, number_to_truncate_to, test_point);
%maxTest = max(abs(truncated_test));
%truncated_test = abs(truncated_test)/maxTest;
truncated_test = abs(truncated_test);

%disp(size(base));
%disp(size(truncated_test));
data_test = base'*truncated_test;

[label_test] = knn(5, data_train, label_train, data_test);

if(label_test(1) == 0)
    location = 1;
else
    location = 2;
end
end


    
function [result_vec] = findVec(index, truncated, original_vec)
[m n] = size(original_vec);
if (size(index,1) == 0)
    result_vec = original_vec(m-truncated:m);
elseif(index+truncated <= m)
    result_vec = original_vec(index:index+truncated);
else
    overflow = index + truncated - n;
    result_vec = [original_vec(index:m); zeros(overflow,1)];
end
end

