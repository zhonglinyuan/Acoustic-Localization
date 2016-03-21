function [] = cross_correlation(base,base1)

afile=strcat(base,'_ACCEL.txt');
gfile=strcat(base,'_GYRO.txt');
micfile=strcat(base,'_AUDIO.txt');
afile1=strcat(base1,'_ACCEL.txt');
gfile1=strcat(base1,'_GYRO.txt');
micfile1=strcat(base1,'_AUDIO.txt');


% get data
[DAx,DAy,DAz,DATime,DGx,DGy,DGz,DGTime,DMic,DTimeMic] = getData(afile,gfile,micfile);
[DAx1,DAy1,DAz1,DATime1,DGx1,DGy1,DGz1,DGTime1,DMic1,DTimeMic1] = getData(afile1,gfile1,micfile1);

MicCorrelation=xcorr(DMic,DMic1,'none');
AzCorrelation=xcorr(DAz,DAz1,'none');

% plot and save everything
resultName=strcat(micfile,'.crossCorrelation','.result');

h=figure;
x
plot(MicCorrelation);
xlabel('time');
ylabel('correlation');
print(h,'-dpng',strcat(resultName,'.mic.png'));

h=figure;
plot(AzCorrelation);
xlabel('time');
ylabel('correlation');
print(h,'-dpng',strcat(resultName,'.az.png'));
