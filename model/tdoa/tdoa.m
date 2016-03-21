function [t12 t13 indexAz indexMic indexGyro] = tdoa(DAx,DAy,DAz,DATime,DGx,DGy,DGz,DGmag,DGTime,DMic,DTimeMic)

% constants
AZTHRESHOLD=0.03;
GMAGTHRESHOLD=0.015;
MICTHRESHOLD=20;

% find index corresponding to the first maxima after threshold
indexAz=wavefront(DAz,AZTHRESHOLD);
indexMic=wavefront(DMic,MICTHRESHOLD);
indexGyro=wavefront(DGmag,GMAGTHRESHOLD);

% find time difference from index
% t12 is tdoa between microphone and accel
% t13 is tdoa between accel and gyro
t12=extract_td(indexAz,DATime,indexMic,DTimeMic);
t13=extract_td(indexAz,DATime,indexGyro,DGTime);

% find the first maxima following specified threshold
function [index] = wavefront(input,threshold)

	thresholdvec = input >= threshold;
	pairwisediff = input - circshift(input,1);
	pairwisediff(1)=0;
	pairwisediff(size(pairwisediff))=0;

	stage1=0;
	stage2=0;
	i = 1;
	while stage2 == 0 
		if i >= size(pairwisediff)
			stage2=1;
		elseif stage1==1 && pairwisediff(i)<0
			stage2=1;
			i=i-1;
		elseif thresholdvec(i)== 1 
			stage1=1;
			i = i + 1;
		else
			i = i+1;
		end
	end

	index = i;

% extract time difference
function [t12] = extract_td(sensor1,t1,sensor2,t2)
	t12=t1(sensor1)-t2(sensor2);	
