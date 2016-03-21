function [result realY helperTemplateChanged] = getAllCombinations(data)

%path='/Users/Keith/Projects/super-nb-project/data/20120204';

%data = getDataVersionA(path)

result = {};
resulty = [];
label_count = 1;
resultMic = [];
realY = [];
helperTemplateChanged = [];
templateChanged = 0;
% for each template 1
for template1_class = 1 : size(data,1)
    template1_samples = data{template1_class,2};
    template1_className = data{template1_class,1};
        
    for template1_sample = 1:size(template1_samples,2)
        
    % for each template 2
    for template2_class = template1_class+1 : size(data,1)
        template2_samples = data{template2_class,2};
        template2_className = data{template2_class,1};
%         template_sample = size(template2_samples,2);
%         if template_sample > size(template1_samples,2);
%             template_sample = size(template1_samples,2);
%         end
        for template2_sample = 1 : size(template2_samples,2)
            templateChanged = templateChanged + 1;
            % for each data point
            for templateT_class = [template1_class,template2_class]
                templateT_samples = data{templateT_class,2};
                templateT_className = data{templateT_class,1};
                for templateT_sample = 1 : size(templateT_samples,2)
                    
                    
                    
                    % test location should be one of calibrated location
                    assert(templateT_class == template2_class || templateT_class == template1_class);
                    
                    
                    result{label_count,1} = {template1_samples{:,template1_sample}};
                    result{label_count,2} = {template2_samples{:,template2_sample}};
                    result{label_count,3} = {templateT_samples{:,templateT_sample}};
                    realY(label_count,1) = (templateT_class == template2_class);
                    helperTemplateChanged(label_count,1) = templateChanged;

                    label_count = label_count + 1;

                end
            end
            
        end
    end
end
end
