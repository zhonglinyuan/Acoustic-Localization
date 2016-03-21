function [prediction] = model_xcorr_avg(locT,numT,micData,wheretoplot)

    prediction = [];
    size(locT);
    size(numT);
    
    locxcorr = [];
    for i = 1:size(locT,3)
        for j = 1:numT(i)
            locxcorr(j,i) = max(xcorr(locT(:,j,i),micData,'coeff'));
        end
    end
    
    xcorrResult = [];
    for i=1:size(locT,3)
        xcorrResult(i) = mean(locxcorr(1:numT(i),i));
    end
    
    
    [result prediction]= max(xcorrResult);
    
end

function [result] = corssfft(loc1,loc2)
    
end