function [ predicted_location ] = template_addition( template1, template2, test_data )
%First we will try the onset alignment method

%set the threshold value
threshold = 40;

[m1 n1] = size(template1);
[m2 n2] = size(template2);

indices1 = zeros(n1,1);
indices2 = zeros(n2,1);

%using only absolute values
% template1 = abs(template1);
% template2 = abs(template2);
% test_data = abs(test_data);


for i=1:n1
    if ( find(abs(template1(:,i))>threshold,1) > 0)
        indices1(i) = find(abs(template1(:,i))>threshold,1);
    else
        indices1(i) = 0;
    end
    %indices1(i) = find(template1(:,i)>threshold,1);
end

for i=1:n2
    if (find(abs(template2(:,i))>threshold,1) > 0)
        indices2(i) = find(abs(template2(:,i))>threshold,1);
    else
        indices2(i) = 0;
    end
    %indices2(i) = find(template2(:,i)>threshold,1);
end

indAvg1 = ceil(mean(indices1));
indAvg2 = ceil(mean(indices2));
    
for i=1:n1
    if (indices1(i) > indAvg1)
        delta1 = indices1(i) - indAvg1;
        template1(:,i) = circshift(template1(:,i),-1*delta1);
        template1(m1-delta1+1:m1,i) = zeros(delta1,1);
    elseif (indices1(i) < indAvg1)
        delta2 = indAvg1 - indices1(i);
        template1(:,i) = circshift(template1(:,i),delta2);
        template1(1:delta2,i) = zeros(delta2,1);
    else
        %do nothing
    end
end

for i=1:n2
    if (indices2(i) > indAvg2)
        delta1 = indices2(i) - indAvg2;
        template2(:,i) = circshift(template2(:,i),-1*delta1);
        template2(m2-delta1+1:m2,i) = zeros(delta1,1);
    elseif (indices2(i) < indAvg2)
        delta2 = indAvg2 - indices2(i);
        template2(:,i) = circshift(template2(:,i),delta2);
        template2(1:delta2,i) = zeros(delta2,1);
    else
        %do nothing
    end
end

prediction_template1 = zeros(m1,1);
prediction_template2 = zeros(m2,1);

for i=1:n1
    prediction_template1 = prediction_template1 + template1(:,i);
end
for i=1:n2
    prediction_template2 = prediction_template2 + template2(:,i);
end

prediction_template1 = prediction_template1/n1;
prediction_template2 = prediction_template2/n2;

if (max(xcorr(prediction_template1,test_data,'coeff')) > max(xcorr(prediction_template2,test_data,'coeff')))
    predicted_location = 1;
else
    predicted_location = 2;
end