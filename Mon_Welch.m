function y = Mon_Welch(x,NFFT)
a = [];
lenx = length(x);
Nb_fft = floor(lenx/NFFT);

for i=1:Nb_fft
    xpriv = x(1+(i-1)*NFFT : i*NFFT);
    S = fft(xpriv, NFFT);  %calcul de la FFT sur des fragements du signal
    Smoy = (abs(S).^2);     %moyenne du signal au carré
    a = vertcat(a,Smoy);             %on conserve les segments
end

y = mean(a)/NFFT;
y = fftshift(y);
%%res = smooth(y);                  %lissage DSP


    