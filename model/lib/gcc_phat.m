function result=gcc_phat(b1,b2,wheretoplot)
addpath('../lib');

filteredb1 = filter_phat(b1);
filteredb2 = filter_phat(b2);
phatxcorr = xcorr(filteredb1(1:length(b1)),filteredb2(1:length(b2)),'coeff');
[value index] = max(phatxcorr);
result = value;

return;

b1 = onSet(b1,20,100,4000);
b2 = onSet(b2,20,100,4000);

b1 = (b1 - mean(b1))./(std(b1).^2);
b2 = (b2 - mean(b2))./(std(b2).^2);

b1length = length(b1);          
b1fftlength = pow2(nextpow2(b1length));  
b1f=fft(b1,b1fftlength);
b1fc=conj(b1f);

b2length = length(b2);          
b2fftlength = pow2(nextpow2(b2length)); 
b2f=fft(b2,b2fftlength);

b2fc=conj(b2f);

neuma=(b1f).*(b2fc);

deno=abs(b1f).*abs(b2fc);
denoSCOT = sqrt((b1f).*(b1fc).*b2f.*b2fc);
GPHAT=neuma./deno;
%GPHAT=neuma./denoSCOT;
%GPHAT=neuma;

GPHATi=ifft(GPHAT);
[maxval index] = max(GPHATi);
GPHATiOriginal = ifft(neuma);

result = GPHATiOriginal(index);

end


