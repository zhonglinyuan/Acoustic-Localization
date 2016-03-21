%{
Cross-correlation and convolution are closely-related.
In short, to do convolution with FFTs, you zero-pad the input signals 
(add zeros to the end so that at least half of the wave is "blank")
take the FFT of both signals
multiply the results together (sample-by-sample)
do the inverse FFT
conv = ifft(fft(a and zeroes) * fft(b and zeroes))

You need to do the zero-padding because the FFT method is 
actually circular cross-correlation, meaning the signal wraps around at the ends. 
So you add enough zeros to get rid of the overlap, 
to simulate a signal that is zero out to infinity.

To get cross-correlation instead of convolution, 
you either need to time-reverse one of the signals before doing the FFT, 
or take the complex conjugate of one of the signals after the FFT:

corr = ifft(fft(a and zeroes) * fft(b and zeroes[reversed]))
corr = ifft(fft(a and zeroes) * conj(fft(b and zeroes)))
%}



A = [1:1:10]; %confirmed in xcode
B = [1:1:10]; %confirmed in xcode

%buf zeros to power of 2 size
A = [A 0 0 0 0 0 0];
B = [B 0 0 0 0 0 0];

fft_input_A = [A zeros(1,length(A))]; %confirmed
fft_input_A';
fft_input_B = [B(length(B):-1:1) zeros(1, length(B))]; %confirmed
fft_input_B';

fft_output_A = fft(fft_input_A);
fft_output_A';
fft_output_B = fft(fft_input_B);
fft_output_B';

%everything on top can be precomputed during tap registration
%everything below has to be done on-demand

freq_dom_mult = fft_output_A .* fft_output_B;
freq_dom_mult'

try_cor = ifft(freq_dom_mult);
try_cor'

%length(try_cor)

A = [1:1:10];
B = [1:1:10];
real_cor = xcorr(A, B);
real_cor';
%length(real_cor)
plot(1:1:length(try_cor), try_cor, 'or', 1:1:length(real_cor), real_cor, '.g')

%{
%SECTION 0
A = [1:1:10]; %confirmed in xcode
B = [1:1:10]; %confirmed in xcode

fft_input_A = [A zeros(1,length(A))]; %confirmed
fft_input_B = [B(length(B):-1:1) zeros(1, length(B))]; %confirmed

fft_output_A = fft(fft_input_A);
fft_output_A'
fft_output_B = fft(fft_input_B);
fft_output_B'

freq_dom_mult = fft_output_A .* fft_output_B;
freq_dom_mult'

try_cor = ifft(freq_dom_mult);
try_cor'

%length(try_cor)


real_cor = xcorr(A, B);
real_cor'
%length(real_cor)
plot(1:1:length(try_cor), try_cor, 'or', 1:1:length(real_cor), real_cor, '.g')
%}

%{

%SECTION 1
period = 2;
phi = pi/2+1;
x = 0:0.1:2*period*pi;

A = sin(x) + cos(x);
B = 3*sin(x + phi);
C = rand(length(x),1);

fft_input_A = [A zeros(1,length(A)-1)];
fft_input_B = [B(length(B):-1:1) zeros(1, length(B)-1)];
%length(revB)
try_cor = ifft(fft(fft_input_A) .* fft(fft_input_B));
length(try_cor)

real_cor = xcorr(A, B);
length(real_cor)

%plot(1:1:length(try_cor), try_cor, 'or', 1:1:length(real_cor), real_cor, '.g')

%close all
%SECTION 2
A = 1:1:16;
fft(A)';


%SECTION 3
A = [ 1 2 3 4 5 6 0 0 0 0 0 0 0 0 0 0]
fft(A)'

%}

