function [AL01, AL02, ACap, ML01, ML02, MCap] = readFiles(accelLoc01File, accelLoc02File, accelCaptureFile, micLoc01File, micLoc02File, micCaptureFile)

fid=fopen(accelLoc01File, 'r');
A1=fscanf(fid, 'AzLoc01:%f\n');
fclose(fid);
A1=reshape(A1,1,[]);
A1=transpose(A1);
figure;
%plot(A1)

fid=fopen(accelLoc02File, 'r');
A2=fscanf(fid, 'AzLoc02:%f\n');
fclose(fid);
A2=reshape(A2,1,[]);
A2=transpose(A2);
figure;
%plot(A2)

fid=fopen(accelCaptureFile, 'r');
Ac=fscanf(fid, 'AzCapture:%f\n');
fclose(fid);
Ac=reshape(Ac,1,[]);
Ac=transpose(Ac);
figure;
%plot(Ac)

fid=fopen(micLoc01File, 'r');
M1=fscanf(fid, 'MicLoc01:%f\n');
fclose(fid);
M1=reshape(M1,1,[]);
M1=transpose(M1);
figure;
%plot(M1)

fid=fopen(micLoc02File, 'r');
M2=fscanf(fid, 'MicLoc02:%f\n');
fclose(fid);
M2=reshape(M2,1,[]);
M2=transpose(M2);
figure;
%plot(M2)

fid=fopen(micCaptureFile, 'r');
Mc=fscanf(fid, 'MicCapture:%f\n');
fclose(fid);
Mc=reshape(Mc,1,[]);
Mc=transpose(Mc);
figure;
%plot(Mc)

AL01=A1;
AL02=A2;
ACap=Ac;
ML01=M1;
ML02=M2;
MCap=Mc;
end
