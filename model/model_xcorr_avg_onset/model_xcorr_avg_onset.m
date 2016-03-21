function [result] = model_xcorr_avg_onset(locT,num,micData,wheretoplot)

    addpath('../lib');
    addpath('../model_xcorr_avg');
    persistent loc;
    if nargin == 1
        loc = [];
        for class = 1:size(locT,3)
            for i = 1:size(locT,2)
                vec = onSet(locT(:,i,class),800,4096);
                loc(:,i,class) = vec;
            end
        end
        return;
    end
    
    vec = onSet(micData,800,4096);
    
    result=model_xcorr_avg(loc,num,vec,wheretoplot);

end
