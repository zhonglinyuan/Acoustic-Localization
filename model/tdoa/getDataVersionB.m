function [result] = getDataVersionB(path) 

%path='/home/keith/projects/super-nb-project/data/20121126_tap';

%make a vector of all the bins
classNames = dir(strcat(path,'/','*'));
%find how many bins there are
numClasses = size(classNames,1);

result = cell(size(classNames,1),1);

%for each of the bins
for class_i=1:numClasses;
    dirName = classNames(class_i).name;
    result{class_i,1} = dirName;

    filenames = dir(strcat(path,'/',dirName,'/*AUDIO.txt'));
	num_files = size(filenames,1);

	tmp = {};
	% go through each tapping
	for file_i = 1:num_files;
		micName = filenames(file_i).name;
		accelName =  regexprep(micName,'AUDIO\.txt', 'ACCEL.txt');
		gyroName =  regexprep(micName,'AUDIO\.txt', 'GYRO.txt');
        [Ax,Ay,Az,TA,Gx,Gy,Gz,TG,Mic,TMic] = getData(strcat(path,'/',dirName,'/',accelName),strcat(path,'/',dirName,'/',gyroName),strcat(path,'/',dirName,'/',micName));
        tmp{1,file_i} = Ax;
        tmp{2,file_i} = Ay;
        tmp{3,file_i} = Az;
        tmp{4,file_i} = Gx;
        tmp{5,file_i} = Gy;
        tmp{6,file_i} = Gz;
        tmp{7,file_i} = Mic;
	end
    result{class_i,2} = tmp;
end
