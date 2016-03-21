function [result] = model_xcorr_avg_subsampling(locT,num,micData,wheretoplot)

    addpath('../lib');
    addpath('../model_xcorr_avg');
    persistent loc;
    if nargin == 1
        loc = [];
        for class = 1:size(locT,3)
            for i = 1:size(locT,2)
                vec = locT(:,i,class);
                vec1 = vec(1:4:end);
                vec2 = vec(2:4:end);
                vec3 = vec(3:4:end);
                vec4 = vec(4:4:end);
                vec = mean([vec1';vec2';vec3';vec4'])';
                %vec = decimate(vec,2);
                loc(:,i,class) = vec;
            end
        end
        return;
    end
    
   
    
    vec = micData;
                   % vec = decimate(micData,2);
    vec1 = vec(1:4:end);
                vec2 = vec(2:4:end);
                vec3 = vec(3:4:end);
                vec4 = vec(4:4:end);
                vec = mean([vec1';vec2';vec3';vec4'])';
    
    result=model_xcorr_avg(loc,num,vec,wheretoplot);

end
