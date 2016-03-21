function [result] = model_xcorr_max(loc1T,loc2T,micData,wheretoplot)

    loc1xcorr = [];
    loc2xcorr = [];

    for i = 1:size(loc1T,2)
        loc1xcorr(i) = max(xcorr(loc1T(:,i),micData,'coeff'));
        
    end
    for i = 1:size(loc2T,2)
        loc2xcorr(i) = max(xcorr(loc2T(:,i),micData,'coeff'));
    end
    
    %disp('xcorr for loc1:');
    %disp(sprintf('%f ',loc1xcorr));
    %disp('xcorr for loc2:');

    %disp(sprintf('%f ',loc2xcorr));
    if max(loc1xcorr) > max(loc2xcorr)
        result = 1;
    else
        result = 2;
    end
    
    subplot(wheretoplot)
    plot(1:length(loc1xcorr),loc1xcorr,'bo',1:length(loc2xcorr),loc2xcorr,'rx');
    title('prediction_xcorr_avg');

end
