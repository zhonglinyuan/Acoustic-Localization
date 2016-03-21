%test feature_gen

Ax1 = [];
Ay1 = [];
Az1 = [];
Gx1 = [];
Gy1 = [];
Gz1 = [];
Mic1 = [1 -1 1 -1 1 -1 1 -1 1 -1];
loc1 = cell(7,1);
loc1{1} = Ax1;
loc1{2} = Ay1;
loc1{3} = Az1;
loc1{4} = Gx1;
loc1{5} = Gy1;
loc1{6} = Gz1;
loc1{7} = Mic1;

Ax2 = [];
Ay2 = [];
Az2 = [];
Gx2 = [];
Gy2 = [];
Gz2 = [];
Mic2 = [1 1 1 1 1 1 1 1 1 3];
loc2 = cell(7,1);
loc2{1} = Ax2;
loc2{2} = Ay2;
loc2{3} = Az2;
loc2{4} = Gx2;
loc2{5} = Gy2;
loc2{6} = Gz2;
loc2{7} = Mic2;

Ax3 = [];
Ay3 = [];
Az3 = [];
Gx3 = [];
Gy3 = [];
Gz3 = [];
Mic3 = [1 1 1 1 1 1 1 1 1 3];
loc3 = cell(7,1);
loc3{1} = Ax3;
loc3{2} = Ay3;
loc3{3} = Az3;
loc3{4} = Gx3;
loc3{5} = Gy3;
loc3{6} = Gz3;
loc3{7} = Mic3;

result = cell(1,4);
result{1,1} = loc1;
result{1,2} = loc2;
result{1,3} = loc3;

X = generate_features_verA(result);
disp(X);

actual = [ max(xcorr(Mic1, Mic3)) max(xcorr(Mic2, Mic3))];
disp(actual);

