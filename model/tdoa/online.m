%% online testing
function [] = online();

addpath('VectorSpace');
addpath('../lib');
addpath('../model_xcorr_baseline');
addpath('../model_xcorr_avg');
addpath('../model_xcorr_unsupervised');
addpath('../model_gcc_avg');
addpath('../model_xcorr_max');
addpath('../model_xcorr_avg_dynamic_template_selection');

path='../wifi/received';

PATH_MATLAB_COLLECTION = '../../data/matlab_collection_multiple';

S.allplot = figure();
S.plotsub1 = subplot(3,3,1);
S.plotsub2 = subplot(3,3,2);
S.plotsub3 = subplot(3,3,3);
S.plotsub4 = subplot(3,3,4);
S.plotsub5 = subplot(3,3,5);
S.plotsub6 = subplot(3,3,6);
S.plotsub7 = subplot(3,3,7);
S.plotsub8 = subplot(3,3,8);
S.plotsub9 = subplot(3,3,9);
S.analysis_signal_xcorrcumsum = S.plotsub6;
S.fhprediction_xcorr_avg = S.plotsub5;
S.fhprediction_xcorr_unsupervised1 = S.plotsub6;
S.fhprediction_xcorr_unsupervised2 = S.plotsub7;
S.fhprediction_xcorr_unsupervised3 = S.plotsub8;
S.fhprediction_gcc_avg = S.plotsub8;
S.fhprediction_xcorr_max = S.plotsub9;
S.fhprediction_xcorr_avg_template_filtering = S.plotsub9;
S.result = S.plotsub9;
S.analysis_template_xcorr1 = S.plotsub1;
S.analysis_template_xcorr2 = S.plotsub2;
S.analysis_template_accurac_vs_templatenum = S.plotsub3;
S.analysis_signal_fft = S.plotsub7;
S.analysis_onset = S.plotsub7;
S.fh = S.plotsub4;
S.pb = uicontrol('string','next','callback',{@pb_callnext},'units','pixels','position',[10 10 80 30]);
S.pb1 = uicontrol('string','prev','callback',{@pb_callprev},'units','pixels','position',[100 10 80 30]);
S.pb2 = uicontrol('string','restart','callback',{@pb_callrestart},'units','pixels','position',[200 10 80 30]);
playnotes();
locT = [];
numT = [];

STATE_SAVE_FILE = -1;
STATE_IDLE = 0;
STATE_TEST = 9;

state = STATE_IDLE;

firstEnterTest = 0;
drawnow;
filenames = dir(path);
for file_i = 1:size(filenames,1)
        if filenames(file_i).isdir == 1
            continue;
        end
        micName = filenames(file_i).name;
        micName = strcat(path,'/',micName);
        disp(sprintf('deleting %s\n',micName));
        delete(micName);
end

while 1
    filenames = dir(path);
        drawnow;

    for file_i = 1:size(filenames,1)
        if filenames(file_i).isdir == 1
            continue;
        end
        tic;
        micName = fullfile(path,filenames(file_i).name);      
        micData = load(micName)';
        t1 = toc;
        tic;
        if (length(micData) ~= 8192)
            disp(sprintf('WARNING(skip data): mic data length is not 10240(%d)',length(micData)));
            delete(micName);
            continue;
        end   
        
        if (std(micData) < 2 || max(abs(micData)) < 20)
            disp(sprintf('WARNING(skip data): data noise:std:%f max:%f',std(micData),max(abs(micData))));
            delete(micName);
            continue;
        end
        
        [maxvalue maxindex] = max(abs(micData));
        if (maxindex < 500)
            disp(sprintf('WARNING(skip data): max too close to start:%d',maxindex));
            delete(micName);
            continue;
        end
        t2 = toc;
        tic;     
        if state == STATE_TEST
            if firstEnterTest == 0
                firstEnterTest = 1;
                %model_xcorr_avg_onset(locT);
            end
            
             result = model_xcorr_avg(locT,numT,micData,S.fhprediction_xcorr_avg);
             t3 = toc;
            tic;
            %result = model_xcorr_avg_onset(locT,numT,micData,S.fhprediction_xcorr_avg);
            playnotes(result);
            drawnow;
             t4 = toc;
            disp(sprintf('prediction_xcorr_avg thinks you tapped at:%d',result));

            %disp (sprintf('prediction_xcorr_avg_onset thinks you tapped at:%d',result));
            subplot(S.result);
            cla(S.result)
            text(0.5,0.5,sprintf('||%d||',result),'FontSize',30);
            set ( S.result, 'visible', 'off')           
            disp('----------------');
        elseif state == STATE_SAVE_FILE
            saveFile(locT,numT,PATH_MATLAB_COLLECTION);
            state = STATE_IDLE
        elseif state >= 1 && state < STATE_TEST
            if (length(numT) < state)
                numT(state) = 1;
            else
                numT(state) = numT(state) + 1;
            end
            locT(:,numT(state),state) = micData;
            disp(sprintf('adding data to template %d, it now has %d entries',state,numT(state)));
            playnotes(state);
            if (numT(state) >= 30)
                state = state + 1;
            end
        end  
        subplot(S.fh)
        plot(micData);
        disp(sprintf('processing %s',micName));
        
        subplot(S.analysis_onset);
        plot(onSet(micData,800,4096));
        delete(micName);
    end
    
end


function [] = pb_callnext(varargin)
        state = state + 1;
        disp(sprintf('state is now %d',state));
end

function [] = pb_callprev(varargin)
        state = state - 1;
        firstEnterTest = 0;
        disp(sprintf('state is now %d',state));
end

function [] = pb_callrestart(varargin)
        state = STATE_IDLE;
        firstEnterTest = 0;
        locT = [];
        numT = [];
        disp(sprintf('state is now %d',state));
end 
end


function [] = saveFile(loc,num,path)
    reply = input('Do you want more? Y/N [Y]: ', 's');
    if isempty(reply)
        reply = 'Y';
    end
    if reply == 'Y'
            reply = input('Add a suffix: ', 's');
        fileName = sprintf('%f',clock);
        fileName = strcat(path,'/',fileName,'_',reply,'.mat');
        save(fileName,'loc','num');
    end
end