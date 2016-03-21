function [result] = getDataVersionA() 

path='../../data/fakeData20130217_two_loc';

%foldernames = dir(strcat(path,'/','*'));

result = {};
label_count = 1;
% go through all setup subdirectories
allSetupDir = getAllSubDir(path);

for setup_i = 1:size(allSetupDir,1)
    setupName = allSetupDir{setup_i};
    setupDir = strcat(path,'/',setupName);
    allLocDir = getAllSubDir(setupDir);
    % go through all tap location
    for loc_i = 1:size(allLocDir,1)
        locName = allLocDir{loc_i};
        locDir = strcat(setupDir,'/',locName);
        
        result{label_count,1} = locDir;
        
        % go through all taps at that location
        tmp = {};
        filenames = dir(strcat(locDir,'/*_Mic_*.txt'));
        for file_i = 1:size(filenames,1)
            micName = filenames(file_i).name;
            micName = strcat(locDir,'/',micName);
            accelxName = regexprep(micName,'_Mic_', '_AccX_');
            accelyName = regexprep(micName,'_Mic_', '_AccY_');
            accelzName = regexprep(micName,'_Mic_', '_AccZ_');

            gyroxName = regexprep(micName,'_Mic_', '_GyroX_');
            gyroyName = regexprep(micName,'_Mic_', '_GyroY_');
            gyrozName = regexprep(micName,'_Mic_', '_GyroZ_');
            
            tmp{1,file_i} = load(accelxName);
            tmp{2,file_i} = load(accelyName);
            tmp{3,file_i} = load(accelzName);
            tmp{4,file_i} = load(gyroxName);
            tmp{5,file_i} = load(gyroyName);
            tmp{6,file_i} = load(gyrozName);
            tmp{7,file_i} = load(micName);
            tmp{8,file_i} = micName;
        end
        
        result{label_count, 2} = tmp;
        label_count = label_count + 1;
    end
end

end

