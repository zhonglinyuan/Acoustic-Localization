function [ result ] = preProcess( data )
%PREPROCESS Summary of this function goes here
%   Detailed explanation goes here
figure()
for template_class = 1 : size(data,1)
	template_samples = data{template_class,2};
	template_className = data{template_class,1};
    for template_sample = 1 : size(template_samples,2)

        mic_data = template_samples{7,template_sample};
        
        [max_V max_I] = max(mic_data);
        
        
        halfWindow = 10*256;
        
        left = max_I - halfWindow;
        right = max_I+halfWindow;
        if (left < 1)
            left = 1;
        end
        if (right > size(mic_data,1))
            right = size(mic_data,1);
        end
        template_samples{7,template_sample} = mic_data(left:right,1);
        data{template_class,2} = template_samples;
        
        plot(template_samples{7,template_sample});
        
    
    end
    
    

end

result = data;

