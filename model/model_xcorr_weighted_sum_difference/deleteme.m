


figure()
wheretoplot1 = subplot(2,2,1);
wheretoplot2 = subplot(2,2,2);
wheretoplot3 = subplot(2,2,3);

Label1 = rand(20,5);
Label2 = rand(20,5);

test = rand(20,1);

prediction_weighted_sum_difference(Label1, Label2, test, 3,...
    wheretoplot1, wheretoplot2, wheretoplot3)


%xcorr(randi(20,1), randi(20,1), 'coeff')
%xcorr(rand(20,1), rand(20,1), 'coeff')

%{
A = [ 1 1 1,
      2 2 2]
      %3 3 3,
      %4 4 4]
length(A)
figure
plot(1:length(A), A)
A = [ 1 1 1,
      2 2 2,
      3 3 3,
      4 4 4]
figure
plot(1:length(A), A)
%}
  
  