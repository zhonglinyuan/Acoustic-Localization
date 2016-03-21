function [ predicted_location ] = model_xcorr_unsupervised( templates, test_data,wheretoplot1,wheretoplot2, wheretoplot3 )

persistent finaltmp1;
persistent finaltmp2;
persistent tobeprocessed;
persistent alignvec;
if nargin == 4
    [m1 n1] = size(templates);
    
    corr_matrix1 = zeros(n1);
    
    lags_matrix1 = zeros(n1);
    newtmp1 = zeros(size(templates));
    
    for i=1:n1
        for j=i+1:n1
            tmpXcorr = xcorr(templates(:,i),templates(:,j),'coeff');
            [tmpMax tmpInd] = max(tmpXcorr);
            corr_matrix1(i,j) = tmpMax;
            lags_matrix1(i,j) = tmpInd;
        end
    end
    
    
    %finding the largest element in matrix
    biggest1 = 0;
    
    i1 = 0;
    
    for i=1:n1
        for j=i+1:n1
            if (corr_matrix1(i,j) > biggest1)
                biggest1 = corr_matrix1(i,j);
                i1 = i;
            end
        end
    end
    
    
    %do time shift now for every template
    
    for i=1:n1
        if (i ~= i1)
            newtmp1(:,i) = align_using_xcorr(templates(:,i1),templates(:,i));
        else
            newtmp1(:,i) = templates(:,i);
            alignvec = newtmp1(:,i);
        end
        newtmp1(:,i) = (newtmp1(:,i) - mean(newtmp1(:,i)))/std(newtmp1(:,i));
    end
    
    label = kmeans(newtmp1',2);
    
    
   
    
    finaltmp1 = zeros(size(newtmp1,1),1);
    finaltmp2 = zeros(size(newtmp1,1),1);
    for i = 1:size(label,1)
        if label(i) == 1
            finaltmp1 = finaltmp1 + newtmp1(:,i);
        else
            finaltmp2 = finaltmp2 + newtmp1(:,i);
        end
    end
    subplot(wheretoplot1)
    plot(finaltmp1,'b')
    subplot(wheretoplot2)
    plot(finaltmp2,'r')
    drawnow;
    return;
end

predicted_location = model_xcorr_avg(finaltmp1,finaltmp2,test_data,wheretoplot3);
% tobeprocessed = [tobeprocessed test_data];

% if(size(tobeprocessed,2) > 5)
%     disp('INFO: rerun k-mean');
%     [finaltmp1 finaltmp2] = process_buffer(finaltmp1,finaltmp2,tobeprocessed,alignvec);
%     tobeprocessed = [];
% end

end

function [finaltmp1 finaltmp2] = process_buffer(loc1,loc2,buf,alignvec)
    temp = [loc1 loc2];
    for i = 1:size(buf:2)
        temp(:,end+1) = align_using_xcorr(alignvec,buf(:,i));
        temp(:,end) = (temp(:,end) - mean(temp(:,end)))/std(temp(:,end));
    end
    label = kmeans(temp',2);
    finaltmp1 = zeros(size(temp,1),1);
    finaltmp2 = zeros(size(temp,1),1);
    for i = 1:size(label,1)
        if label(i) == 1
            finaltmp1 = finaltmp1 + temp(:,i);
        else
            finaltmp2 = finaltmp2 + temp(:,i);
        end
    end

end