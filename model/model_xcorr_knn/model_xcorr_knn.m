function [result] = model_xcorr_knn(loc1T,loc2T,micData,wheretoplot,k)

    loc1xcorr = [];
    loc2xcorr = [];

    if k > (size(loc1T,2) +size(loc2T,2))
        k = size(loc1T,2) +size(loc2T,2);
    end
    
    for i = 1:size(loc1T,2)
        loc1xcorr(i) = max(xcorr(loc1T(:,i),micData,'coeff'));
        
    end
    for i = 1:size(loc2T,2)
        loc2xcorr(i) = max(xcorr(loc2T(:,i),micData,'coeff'));
    end
    
    tophalf = k;
    
    [sorted index] = sort([loc1xcorr,loc2xcorr],'descend');
    numloc1 = sum(index(1:tophalf) <= length(loc1xcorr));
    numloc2 = tophalf - numloc1;
    
    if numloc1 > numloc2
        result = 1;
    else
        result = 2;
    end
    

end
