% perform calibration
file = load('data.txt');
ax = file(:,1);
ay = file(:,2);
az = file(:,3);

amagxy = (ax.^2 + ay.^2).^.5;
amagxyz = (amagxy.^2 + az.^2) .^ .5;
azangle = pi/2 - atan(az./amagxy);
azanglemean = mean(azangle);
azangledeviation = std(azangle);
azmean = mean(az);
azdeviation = std(az);

fprintf('azanglemean:%f azangledeviation:%f azmean:%f azdeviation:%f\n',azanglemean,azangledeviation,azmean,azdeviation);