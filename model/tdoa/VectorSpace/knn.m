function [label_test] = knn(k, data_train, label_train, data_test)

error(nargchk(4,4,nargin));

D = size(label_train, 1);

dist = l2_distance(data_train, data_test);
[sorted_dist, nearest] = sort(dist);

%kxN
nearest = nearest(1:k,:);

%takes the label of the M training points, chosen by the ith nearest for
%the N test points
label_test = zeros(D, size(data_test, 2), k);
for i=1:k
    label_test(:,:,i) = label_train(:, nearest(i, :));
end

label_test = mean(label_test,3);
%label_test = label_test == repmat(max(label_test, [], 1), D, 1);