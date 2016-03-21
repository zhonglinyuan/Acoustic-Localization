clear all;
load digits;

%number of principle components
%m = 25;

classification_error = zeros(1,10);
number_of_PComponents = [2:1:40];

i=1;
for m=number_of_PComponents
[base mean projX] = pcaimg([train2, train3],m);
%[base2 mean2 projX2] = pcaimg(train3,m);

data_train = projX;
label_train = [zeros(1,300), ones(1,300); ones(1,300), zeros(1,300)];

data_test = base'*[test2,test3];

[label_test] = knn(1,data_train,label_train,data_test);

tmp = sum((label_test ~= label_train),2)/600;
classification_error(i) = tmp(1);

i = i + 1;
end

plot(number_of_PComponents, classification_error, 'r');
xlabel('number of Principle Components');
ylabel('test classification error');
