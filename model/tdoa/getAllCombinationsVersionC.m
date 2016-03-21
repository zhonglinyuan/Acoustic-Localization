function [result yreal] = getAllCombinationsVersionC(data)

%path='/Users/Keith/Projects/super-nb-project/data/20120204';

%data = getDataVersionA(path)

result = {};
resulty = [];
label_count = 1;
resultMic = [];
% for each setup
for setuptype = 1 : size(data,1)
    setupSamples = data{setuptype,2};
    setupName = data{setuptype,1};
    
    template1 = data{setuptype, 3};
    template2 = data{setuptype, 4};
    
    loc1 = {};
    loc2 = {};
    loc1count = 1;
    loc2count = 1;
    
    for testPoint = 1:size(setupSamples,2)
         actual = setupSamples{8,testPoint};
         
         % bypass template
         if ~isempty (regexp(actual,'_template_','start'))
             fprintf('skip file %s\n',actual);
             continue
         end
         
         actual = regexprep(actual,'.*\d*\.\d*_', '');
         detected = actual;
         actual = regexprep(actual,'_.*', '');
         detected = regexprep(detected,'^\d_','');
         detected = regexprep(detected,'_.*','');
         actual = int32(str2num(actual));
         detected = int32(str2num(detected));
         
         if actual == 1
             loc1{loc1count,1} = {setupSamples{:,testPoint}};
             loc1count = loc1count + 1;
         else
             loc2{loc2count,1} = {setupSamples{:,testPoint}};
             loc2count = loc2count + 1;
         end
    
    end
    
    minsize1 = size(loc1,1);
    comb1 = combnk([1:minsize1],2);
    
    for i=1:length(comb1)
        
        minsize2 = size(loc2,1);
        comb2 = combnk([1:minsize2],2);
        if (max(xcorr(loc1{comb1(i,1)}{7},loc1{comb1(i,2)}{7},'coeff')) < 0.7)
            plot(loc1{comb1(i,1)}{7});
            drawnow
            fprintf('skipped due to bad template:%f\n',max(xcorr(loc1{comb1(i,1)}{7},loc1{comb1(i,2)}{7},'coeff')));
            continue;
        end
        for j=1:length(comb2);
            if (max(xcorr(loc2{comb2(j,1)}{7},loc2{comb2(j,2)}{7},'coeff')) < 0.7)
                disp('skipped due to bad template');
                continue;
            end
            for k = 1:size(loc1,1)
                if comb1(i,1) == k || comb1(i,2) == k
                    continue;
                end
                result{label_count,1} = loc1{comb1(i,1)};
                result{label_count,2} = loc1{comb1(i,2)};
                result{label_count,3} = loc2{comb2(j,1)};
                result{label_count,4} = loc2{comb2(j,2)};
                result{label_count,5} = loc1{k};
                
                yreal(label_count,1) = 0;
                
                label_count = label_count + 1;
            end
            for k = 1:size(loc2,1)
                if comb2(j,1) == k || comb2(j,2) == k
                    continue;
                end
                result{label_count,1} = loc1{comb1(i,1)};
                result{label_count,2} = loc1{comb1(i,2)};
                result{label_count,3} = loc2{comb2(j,1)};
                result{label_count,4} = loc2{comb2(j,2)};
                result{label_count,5} = loc2{k};
                
                yreal(label_count,1) = 1;
                
                label_count = label_count + 1;
            end
        end
    end
end
end
