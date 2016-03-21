function [] = playnotes(notes)

persistent player;
if nargin == 0
    x = 1:2500;
    x = x/10000;
    do = sin(2*pi*440*x);
    re = sin(2*pi*9/8*440*x);
    mi = sin(2*pi*5/4*440*x);
    fa = sin(2*pi*4/3*440*x);
    so = sin(2*pi*3/2*440*x);
    la = sin(2*pi*5/3*440*x);
    ti = sin(2*pi*15/8*440*x);
    do2 = sin(2*pi*2*440*x);
    z = [do;re;mi;fa;so;la;ti;do2];
    Fs = 10000;
    player{1} = audioplayer(do, Fs);
    player{2} = audioplayer(re, Fs);
    player{3} = audioplayer(mi, Fs);
    player{4} = audioplayer(fa, Fs);
    player{5} = audioplayer(so, Fs);
    player{6} = audioplayer(la, Fs);
    player{7} = audioplayer(ti, Fs);
    player{8} = audioplayer(do2, Fs);
    return;
end
playblocking(player{notes});

%sound(z(notes,:), 10000)
end