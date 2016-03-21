function [ predicted_location ] = findVariations( template1, template2, test_data )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[m1 n1] = size(template1);
[m2 n2] = size(template2);

base1 = template1(:,1:2);
base2 = template2(:,1:2);


for i=3:n1
    largest1 = 0;
    largest2 = 0;
    for j=1:size(base1,2)
        if (max(xcorr(template1(:,i),base1(:,j), 'coeff'))>largest1)
            largest1 = max(xcorr(template1(:,i),base1(:,j), 'coeff'));
        end
    end
    for j=1:size(base2,2)
        if (max(xcorr(template1(:,i),base2(:,j), 'coeff'))>largest2)
            largest2 = max(xcorr(template1(:,i),base1(:,j), 'coeff'));
        end
    end
    if largest1 < largest2
        base1 = [base1, template1(:,i)];
    end
end

for i=3:n2
    largest1 = 0;
    largest2 = 0;
    for j=1:size(base1,2)
        if (max(xcorr(template2(:,i),base1(:,j), 'coeff'))>largest1)
            largest1 = max(xcorr(template2(:,i),base1(:,j), 'coeff'));
        end
    end
    for j=1:size(base2,2)
        if (max(xcorr(template2(:,i),base2(:,j), 'coeff'))>largest2)
            largest2 = max(xcorr(template2(:,i),base2(:,j), 'coeff'));
        end
    end
    if largest2 < largest1
        base2 = [base2, template2(:,i)];
    end
end

largest1 = 0;
largest2 = 0;

for i=1:size(base1,2)
    if (max(xcorr(test_data,base1(:,i), 'coeff'))>largest1)
        largest1 = max(xcorr(test_data,base1(:,i), 'coeff'));
    end
end

for i=1:size(base2,2)
    if (max(xcorr(test_data,base2(:,i), 'coeff'))>largest2)
        largest2 = max(xcorr(test_data,base2(:,i), 'coeff'));
    end
end

if (largest1 > largest2)
    predicted_location = 1;
else
    predicted_location = 2;
end
