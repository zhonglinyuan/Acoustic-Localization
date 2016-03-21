function [] = mic_cross_correlation(file_base)

accelLoc01File = strcat(file_base, '_accelLoc01.txt');
accelLoc02File = strcat(file_base, '_accelLoc02.txt');
accelCaptureFile  = strcat(file_base, '_accelCapture.txt');
micLoc01File = strcat(file_base, '_micLoc01.txt');
micLoc02File = strcat(file_base, '_micLoc02.txt');
micCaptureFile = strcat(file_base, '_micCapture.txt');

resultName='micCrossCorr';
[AL01, AL02, ACap, ML01, ML02, MCap] = readFiles(accelLoc01File, accelLoc02File, accelCaptureFile, micLoc01File, micLoc02File, micCaptureFile);

plot(AL01)
title('accel z loc01')
figure
plot(AL02)
title('accel z loc02')
figure
plot(ACap)
title('accel z captured')
figure
plot(ML01)
title('mic loc01')
figure
plot(ML02)
title('mic loc02')
figure
plot(MCap)
title('mic captured')

MicLoc01CrossCorr = xcorr(ML01,MCap,'none');
MicLoc02CrossCorr = xcorr(ML02,MCap,'none');

Loc01XCorrMax = max(MicLoc01CrossCorr);
Loc01XCorrMax

Loc02XCorrMax = max(MicLoc02CrossCorr);
Loc02XCorrMax

min(MicLoc)

f=figure;
plot(MicLoc01CrossCorr);
title('mic loc01 crosscorr')
xlabel('sample step');
ylabel('MicLoc01 xcorr MicCap');
print(f,'-dpng',strcat(resultName,'MicL01Cap.png'));

f=figure;
plot(MicLoc02CrossCorr);
title('mic loc02 crosscorr')
xlabel('sample step');
ylabel('MicLoc02 xcorr MicCap');
print(f,'-dpng',strcat(resultName,'MicL02Cap.png'));

%plot(fft(MicLoc01CrossCorr))
%figure
%plot(fft(MicLoc01CrossCorr))
end