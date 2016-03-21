function [] = analysis_signal_xcorrcumsum (template,micData,wheretoplot)

[maxnum, maxindex] = max(xcorr(template,micData,'coeff'));
maxindex = maxindex - length(micData);
temp = [];

subplot(wheretoplot);
title('analysis_signal_xcorrcumsum');

if (maxindex >= 0)
    maxindex = maxindex + 1;
    temp = template(maxindex:end,1).*micData(1:(end-maxindex+1),1);
else
    maxindex = maxindex * -1+1;
    temp = template(1:(end-maxindex+1),1).*micData(maxindex:end,1);
end
plot(cumsum(temp));
end