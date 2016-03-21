function [Ax,Ay,Az,TA,Gx,Gy,Gz,TG,Mic,TMic] = getData(afile,gfile,micfile) 

% open file and get the data into matrix A
fid=fopen(afile,'r');
A=fscanf(fid,'Ax:%f Ay:%f Az:%f accelClock:%f\n');
fclose(fid);
A=reshape(A,4,[]);
A=transpose(A);

fid=fopen(gfile,'r');
G=fscanf(fid,'Gx:%f Gy:%f Gz:%f gyroClock:%f\n');
fclose(fid);
G=reshape(G,4,[]);
G=transpose(G);

fid=fopen(micfile,'r');
B=fscanf(fid,'(Audio):%d (Mclock):%f\n');
fclose(fid);
B=reshape(B,2,[]);
B=transpose(B);

TA=A(:,4);
Ax=A(:,1);
Ay=A(:,2);
Az=A(:,3);

TG=G(:,4);
Gx=G(:,1);
Gy=G(:,2);
Gz=G(:,3);

B(:,3)=linspace(B(1,2),B(end,2),size(B,1));
TMic=B(:,3);
Mic=B(:,1);
