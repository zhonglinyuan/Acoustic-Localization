function [] = tdoa_wrapper(base)

afile=strcat(base,'_ACCEL.txt');
gfile=strcat(base,'_GYRO.txt');
micfile=strcat(base,'_AUDIO.txt');

% get data
[DAx,DAy,DAz,DATime,DGx,DGy,DGz,DGTime,DMic,DTimeMic] = getData(afile,gfile,micfile);

[DAx DAy DAz DATime DGx DGy DGz DGmag DGangle DGTime DMic DTimeMic] = preprocess_data(DAx,DAy,DAz,DATime,DGx,DGy,DGz,DGTime,DMic,DTimeMic);

% find tdoa
[t12 t13 indexAz indexMic indexGyro] = tdoa(DAx,DAy,DAz,DATime,DGx,DGy,DGz,DGmag,DGTime,DMic,DTimeMic);


% only need one second before and after
windowAccelB=10;
windowAccelA=100;
if indexAz-windowAccelB - 1 > 0
	DAz(1:(indexAz-windowAccelB-1))=[];
	DATime(1:(indexAz-windowAccelB-1))=[];
	indexAz=windowAccelB+1;
end
DAz(indexAz+windowAccelA+1:end)=[];
DATime(indexAz+windowAccelA+1:end)=[];

windowMicB=100;
windowMicA=1000;
if indexMic-windowMicB- 1 > 0
	DMic(1:(indexMic-windowMicB-1))=[];
	DTimeMic(1:(indexMic-windowMicB-1))=[];
	indexMic=windowMicB+1;
end
DMic(indexMic+windowMicA+1:end)=[];
DTimeMic(indexMic+windowMicA+1:end)=[];

% extrac other features
max2avg=max(DMic)/mean(DMic);
variance=var(DMic);

% plot and save everything
resultName=strcat(base,'_result');

fprintf('RESULT:%f (%s)\n',t12,micfile);

h=figure;

%subplot(3,3,1);
%plot(DATime,DAx);
%xlabel('time');
%ylabel('ax');
%
%subplot(3,3,2);
%plot(DATime,DAy);
%xlabel('time');
%ylabel('ay');
%
subplot(5,1,1);
plot(DATime,DAz);
hold on;
xlabel('time');
ylabel('az');
plot(DATime(indexAz),DAz(indexAz),'--rs');
hold off

%subplot(3,3,4);
%plot(DGTime,DGx);
%xlabel('time');
%ylabel('gx');
%
%subplot(3,3,5);
%plot(DGTime,DGy);
%xlabel('time');
%ylabel('gy');
%
subplot(5,1,2);
plot(DTimeMic,DMic);
hold on;
plot(DTimeMic(indexMic),DMic(indexMic),'--rs');
xlabel('time');
ylabel('mic');
hold off;

%subplot(3,1,3);
%plot(DGTime,DGmag);
%xlabel('time');
%ylabel('gmag');
%

subplot(5,1,3)
plot(DGTime,DGmag);
hold on;
plot(DGTime(indexGyro),DGmag(indexGyro),'--rs');
xlabel('time');
ylabel('DGmag');
hold off;

subplot(5,1,4)
plot(DGTime,DGangle);
hold on;
plot(DGTime(indexGyro),DGangle(indexGyro),'--rs');
xlabel('time');
ylabel('DGangle');
hold off

subplot(5,1,5)
text(.5,.5,strcat('tdoa:(',num2str(t12),')(',num2str(t13),')', 'angle:',num2str(DGangle(indexGyro)),' max2avg: ',num2str(max2avg)), 'FontSize',14,'HorizontalAlignment','center')

print(h,'-dpng',strcat(resultName,'.png'));
