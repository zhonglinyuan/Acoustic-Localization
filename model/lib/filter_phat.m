function vec = filter_phat(b1)

b1length = length(b1);          
b1fftlength = pow2(nextpow2(b1length));  
b1f=fft(b1,b1fftlength);

neuma=(b1f);
deno=abs(b1f);

GPHAT = neuma./deno;
GPHATi=ifft(GPHAT);

vec = GPHATi;
end