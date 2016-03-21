function [result] = model_gcc_avg(loc1T,loc2T,micData,wheretoplot)
    addpath('../lib');
    loc1xcorr = [];
    loc2xcorr = [];

    for i = 1:size(loc1T,2)
        loc1xcorr(i) = gcc_phat(loc1T(:,i),micData,wheretoplot);
        
    end
    for i = 1:size(loc2T,2)
        loc2xcorr(i) = gcc_phat(loc2T(:,i),micData,wheretoplot);
    end
    
    
    if mean(loc1xcorr) > mean(loc2xcorr)
        result = 1;
    else
        result = 2;
    end
    
    subplot(wheretoplot)
    %cla(wheretoplot);
    %plot(filter_phat(micData));
    %plot(1:length(loc1xcorr),loc1xcorr,'bo',1:length(loc2xcorr),loc2xcorr,'rx');
    
    title('prediction_gcc_avg'); 
end