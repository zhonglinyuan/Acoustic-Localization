function [] = analysis_template_xcorr(loc1T,loc2T,plot1,plot2)
subplot(plot1);           
title('template 1 performance on all templates');

hold on;
for i=1:size(loc1T,2)
    xcorr_result = xcorr_all_vec(loc1T,loc1T(:,i));
    plot(ones(length(xcorr_result))*i, xcorr_result,'bo');
    xcorr_result = xcorr_all_vec(loc2T,loc1T(:,i));
    plot(ones(length(xcorr_result))*i, xcorr_result,'rx');
end

subplot(plot2);
title('template 2 performance on all templates');

hold on;

for i=1:size(loc2T,2)
    xcorr_result = xcorr_all_vec(loc1T,loc2T(:,i));
    plot(ones(length(xcorr_result))*i, xcorr_result,'bo');
    xcorr_result = xcorr_all_vec(loc2T,loc2T(:,i));
    plot(ones(length(xcorr_result))*i, xcorr_result,'rx');
end

end

