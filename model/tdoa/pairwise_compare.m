function [result] = pairwise_compare()

%path='/home/keith/projects/super-nb-project/data/20121126_tap/max_tap';
path='/Users/Keith/Projects/super-nb-project/data/collected_data_nov21_2012_a';
%path = '/nfs/ug/homes-1/z/zhouweij/projects/capstone/data/collected_data_nov21_2012';

data = getDataVersionB(path);
data = preProcess(data);

num_correct = 0;
num_wrong = 0;
% for each template 1
for template1_class = 1 : size(data,1)
	template1_samples = data{template1_class,2};
	template1_className = data{template1_class,1};
	for template1_sample = 1 : size(template1_samples,2)

		% for each template 2
		for template2_class = template1_class+1 : size(data,1)
			template2_samples = data{template2_class,2};
	        template2_className = data{template2_class,1};
			for template2_sample = 1 : size(template2_samples,2)
                
                % for each template 3
                for template3_class = template2_class+1 : size(data,1)
                	template3_samples = data{template3_class,2};
                    template3_className = data{template3_class,1};
                    for template3_sample = 1 : size(template3_samples,2)

                        % for each data point
                        for templateT_class = [template1_class,template2_class,template3_class]
                            templateT_samples = data{templateT_class,2};
                            templateT_className = data{templateT_class,1};
                            for templateT_sample = 1 : size(templateT_samples,2)
                                
                                % test location should be one of calibrated location
                                assert(templateT_class == template2_class || templateT_class == template1_class || templateT_class == template3_class);
                                
                                % get microphone data
                                data3 = template3_samples{7,template3_sample};
                                data2 = template2_samples{7,template2_sample};
                                data1 = template1_samples{7,template1_sample};
                                dataT = templateT_samples{7,templateT_sample};
                                
                                
                              
                                resultA = max(xcorr(dataT,data1));
                                resultB = max(xcorr(dataT,data2));
                                resultC = max(xcorr(dataT,data3));
                                
                                [maxValue maxIndex] = max([resultA;resultB;resultC]);
                                
                                
                                if ( ((maxIndex == 1) && (templateT_class == template1_class)) || ((maxIndex == 2) && (templateT_class == template2_class)) || ((maxIndex == 3) && (templateT_class == template3_class)))
                                    num_correct = num_correct + 1;
                                else
                                    num_wrong = num_wrong + 1;
                                end
                                fprintf('(t1:%s(%f) t2:%s(%f) t3:%s(%f) tT:%s)correct:%d wrong:%d\n',template1_className,resultA,template2_className,resultB,template3_className,resultC,templateT_className,num_correct,num_wrong);
                                if inOctave()
                                    fflush(stdout);
                                end
                            end
                        end
                    end
                end
            end
		end
	end
end
