function [result] = model_xcorr_avg_dynamic_template_selection(loc1T,loc2T,micData,wheretoplot)
addpath('../lib');

    persistent loc1Tp;
    persistent loc2Tp;
    
    if nargin == 2
        [loc1Tp,loc2Tp] = filter_template_xcorr(loc1T,loc2T, 5);
        return;
    end

    result = model_xcorr_avg(loc1Tp,loc2Tp,micData,wheretoplot);
    if (result == 1)
        [loc1Tp,loc2Tp] = filter_template_xcorr([loc1Tp micData],loc2Tp, 5);
    else
        [loc1Tp,loc2Tp] = filter_template_xcorr(loc1Tp,[loc2Tp micData], 5);
    end
end
