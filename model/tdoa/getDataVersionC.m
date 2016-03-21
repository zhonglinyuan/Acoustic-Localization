function [result] = getDataVersionC() 
% file format. a long list of data
% directory format: setup/all files. assume all templates are the same

path='../../data/a';

%foldernames = dir(strcat(path,'/','*'));

result = {};
label_count = 1;
% go through all setup subdirectories
allSetupDir = getAllSubDir(path);

for setup_i = 1:size(allSetupDir,1)
    setupName = allSetupDir{setup_i};
    setupDir = strcat(path,'/',setupName);
    % go through all tap location
        result{label_count,1} = setupDir;
        
        % go through all taps at that location
        tmp = {};
        filenames = dir(strcat(setupDir,'/*Mic.txt'));
        for file_i = 1:size(filenames,1)
            micName = filenames(file_i).name;
            micName = strcat(setupDir,'/',micName);
            accelxName = regexprep(micName,'_Mic', '_AccX');
            accelyName = regexprep(micName,'_Mic', '_AccY');
            accelzName = regexprep(micName,'_Mic', '_AccZ');

            gyroxName = regexprep(micName,'_Mic', '_GyroX');
            gyroyName = regexprep(micName,'_Mic', '_GyroY');
            gyrozName = regexprep(micName,'_Mic', '_GyroZ');
            
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
        
        % get template
        tmp = {};
        filenames = dir(strcat(setupDir,'/*_1_template_Mic.txt'));
        for file_i = 1:1;
            micName = filenames(file_i).name;
            micName = strcat(setupDir,'/',micName);
            accelxName = regexprep(micName,'_Mic', '_AccX');
            accelyName = regexprep(micName,'_Mic', '_AccY');
            accelzName = regexprep(micName,'_Mic', '_AccZ');

            gyroxName = regexprep(micName,'_Mic', '_GyroX');
            gyroyName = regexprep(micName,'_Mic', '_GyroY');
            gyrozName = regexprep(micName,'_Mic', '_GyroZ');
            
            tmp{1,file_i} = load(accelxName);
            tmp{2,file_i} = load(accelyName);
            tmp{3,file_i} = load(accelzName);
            tmp{4,file_i} = load(gyroxName);
            tmp{5,file_i} = load(gyroyName);
            tmp{6,file_i} = load(gyrozName);
            tmp{7,file_i} = load(micName);
            tmp{8,file_i} = micName;
        end
        result{label_count, 3} = tmp;
        
        tmp = {};
        filenames = dir(strcat(setupDir,'/*_2_template_Mic.txt'));
        for file_i = 1:1;
            micName = filenames(file_i).name;
            micName = strcat(setupDir,'/',micName);
            accelxName = regexprep(micName,'_Mic', '_AccX');
            accelyName = regexprep(micName,'_Mic', '_AccY');
            accelzName = regexprep(micName,'_Mic', '_AccZ');

            gyroxName = regexprep(micName,'_Mic', '_GyroX');
            gyroyName = regexprep(micName,'_Mic', '_GyroY');
            gyrozName = regexprep(micName,'_Mic', '_GyroZ');
            
            tmp{1,file_i} = load(accelxName);
            tmp{2,file_i} = load(accelyName);
            tmp{3,file_i} = load(accelzName);
            tmp{4,file_i} = load(gyroxName);
            tmp{5,file_i} = load(gyroyName);
            tmp{6,file_i} = load(gyrozName);
            tmp{7,file_i} = load(micName);
            tmp{8,file_i} = micName;
        end
        result{label_count, 4} = tmp;
        
        label_count = label_count + 1;
end

end
