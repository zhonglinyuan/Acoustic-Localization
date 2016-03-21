
%input_cell is a cell type with:
%col_1:mat_type col_2:mat_type col_3:mat_type label:int

function [X] = generate_features_verA(input_cell)

    %legned
    [input_cell_rows input_cell_cols] = size(input_cell);
    T = input_cell_rows;
    X = zeros(T, 6);

    Ax_t = 1;
    Ay_t= 2;
    Az_t=3;
    Gx_t=4;
    Gy_t=5;
    Gz_t=6;
    Mic_t=7;

    testloc_position = input_cell_cols; %testloc is always second last position
    
    
    
    
    %Mic cross-corr feature extraction
    parfor t=1:T
                loc1a = input_cell{t,1};
                loc1b = input_cell{t,2};
                loc2a = input_cell{t,3};
                loc2b = input_cell{t,4};
                testloc = input_cell{t,testloc_position};


                loc1a_mic = loc1a{Mic_t};
                loc1b_mic = loc1b{Mic_t};
                loc2a_mic = loc2a{Mic_t};
                loc2b_mic = loc2b{Mic_t};
                testloc_mic = testloc{Mic_t};
               
                
%                 loc1_az = loc1{Az_t};
%                 loc2_az = loc2{Az_t};
%                 testloc_az = testloc{Az_t};
%                 
%                 loc1_ax = loc1{Ax_t};
%                 loc1_ay = loc1{Ay_t};
%                 loc2_ax = loc2{Ax_t};
%                 loc2_ay = loc2{Ay_t};
%                 testloc_ax = testloc{Ax_t};
%                 testloc_ay = testloc{Ay_t};
% 
%                 loc1_gx = loc1{Gx_t};
%                 loc1_gy = loc1{Gy_t};
%                 loc2_gx = loc2{Gx_t};
%                 loc2_gy = loc2{Gy_t};
%                 testloc_gx = testloc{Gx_t};
%                 testloc_gy = testloc{Gy_t};
                
                
                
                X(t,:) = [x_corr(loc1a_mic, loc1b_mic) x_corr(loc2a_mic, loc2b_mic) x_corr(loc1a_mic, testloc_mic) x_corr(loc1b_mic, testloc_mic) x_corr(loc2a_mic, testloc_mic) x_corr(loc2b_mic, testloc_mic)];
%                 X(t, 2) = x_corr(loc2a_mic, loc2b_mic);
%                 X(t, 3) = x_corr(loc1a_mic, testloc_mic);
%                 X(t, 4) = x_corr(loc1b_mic, testloc_mic);
%                 X(t, 5) = x_corr(loc2a_mic, testloc_mic);
%                 X(t, 6) = x_corr(loc2b_mic, testloc_mic);
%                X(t,:) = max(xcorr([testloc_mic loc1a_mic loc1b_mic loc2a_mic loc2b_mic],'coeff'));
%\                 X(t, 3) = x_corr(loc1_az, testloc_az);
%                 X(t, 4) = x_corr(loc2_az, testloc_az);
%                 X(t, 5) = x_corr(loc1_ax, testloc_ax);
%                 X(t, 6) = x_corr(loc2_ax, testloc_ax);
%                 X(t, 7) = x_corr(loc1_ay, testloc_ay);
%                 X(t, 8) = x_corr(loc2_ay, testloc_ay);
%                 X(t, 9) = x_corr((loc1_ax.^2 + loc1_ay.^2).^0.5, (testloc_ax.^2 + testloc_ay.^2).^0.5);
%                 X(t, 10) = x_corr((loc2_ax.^2 + loc2_ay.^2).^0.5, (testloc_ax.^2 + testloc_ay.^2).^0.5);
%                 X(t, 11) = x_corr((loc1_gx.^2 + loc1_gy.^2).^0.5, (testloc_gx.^2 + testloc_gy.^2).^0.5);
%                 X(t, 12) = x_corr((loc2_gx.^2 + loc2_gy.^2).^0.5, (testloc_gx.^2 + testloc_gy.^2).^0.5);
%                 X(t, 13) = x_corr(loc1_gx, testloc_gx);
%                 X(t, 14) = x_corr(loc2_gx, testloc_gx);
%                 X(t, 15) = x_corr(loc1_gy, testloc_gy);
%                 X(t, 16) = x_corr(loc2_gy, testloc_gy);
%         
%                 NumTestLocZeroCrossMic = zerocrossing(testloc_mic);
%                 X(t, 17) =    NumTestLocZeroCrossMic/(zerocrossing(loc1_mic)+1);
%                 X(t, 18) =  NumTestLocZeroCrossMic/(zerocrossing(loc2_mic)+1);            
%             
%                 NumTestLocZeroCrossAz = zerocrossing(testloc_az +1);
%                 X(t, 19) = NumTestLocZeroCrossAz/(zerocrossing(loc1_az+1)+1);
%                 X(t, 20) = NumTestLocZeroCrossAz/(zerocrossing(loc2_az+1)+1);
%                 
%                 
%                 [loc1max loc1maxi]= max(loc1_mic);
%                 [loc2max loc2maxi]= max(loc2_mic);
%                 [testlocmax testlocmaxi]= max(testloc_mic);
                
                %loc1fit = fit([1:(length(loc1_mic) - loc1maxi+1)]',abs(loc1_mic(loc1maxi:end,1)),'exp1');
                %loc2fit = fit([1:(length(loc2_mic) - loc2maxi+1)]',abs(loc2_mic(loc2maxi:end,1)),'exp1');
                %testlocfit = fit([1:(length(testloc_mic) - testlocmaxi+1)]',abs(testloc_mic(testlocmaxi:end,1)),'exp1');
                %X(t,21) = testlocfit.b/loc1fit.b;
                %X(t, 22) = testlocfit.b/loc2fit.b;
                
%                 [loc1max loc1maxi]= max(loc1_az);
%                 [loc2max loc2maxi]= max(loc2_az);
%                 [testlocmax testlocmaxi]= max(testloc_az);
%                 
                %loc1fit = fit([1:(length(loc1_az) - loc1maxi+1)]',abs(loc1_az(loc1maxi:end,1)),'exp1');
                %loc2fit = fit([1:(length(loc2_az) - loc2maxi+1)]',abs(loc2_az(loc2maxi:end,1)),'exp1');
                %testlocfit = fit([1:(length(testloc_az) - testlocmaxi+1)]',abs(testloc_az(testlocmaxi:end,1)),'exp1');
                %X(t, 23) = testlocfit.b/loc1fit.b;
                %X(t, 24) =- testlocfit.b/loc2fit.b;
                   
    end    
end

function [crossings] = zerocrossing(x)
    i = 1:length(x)-1;
    crossings= length(find( (x(i)>=0 & x(i+1) < 0) | (x(i) <=0 & x(i+1) > 0)));
end

function [xcorr_max_result] = x_corr(A, B)
xcorr_max_result= xcorr(A,B,'coeff');
xcorr_max_result = max(xcorr_max_result);
end

function [xcorr_max_result] = x_corr_fft(A,B)
[Af, Ay] = getFFT(A,44100);
[Bf, By] = getFFT(B,44100);
xcorr_max_result = x_corr(Ay,By);
end