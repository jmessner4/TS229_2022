clear; close all; clc;

% % Constantes

NFFT = 256;             %Nombre de points pour effectuer la FFT
Fe = 20e6;              %Fréquence d'échantillonage
Ts = 1e-6;              %Période symbole
Fse = Ts*Fe;            %Nombre d'échantillon
Nb = 1000;              %Nombre de points
bk = randi([0,1],1,Nb); %bits envoyés

% % Sous-tâche 5
    %PPM
sl=PPM(bk,Nb);
lens=length(sl);
    %Suréchantillonnage
slsur=upsample(sl,Fse/2);
lenss=length(slsur);

filtre=ones(1,Fse/2);
slf=conv(slsur,filtre);

    %Calcul de la DSP via le périodogramme de Welch
dsp = Mon_Welch(slf,NFFT);

    %DSP théorique
f = -Fe/2 : Fe/(NFFT-1) : Fe/2;
dir = dirac(f-f(NFFT/2));
id = dir == Inf;
dir(id) = 1;
Dsp_th = 0.25.*dir + Ts*((sinc((Ts/2)*f).^2).*((sin(pi*(Ts/2)*f)).^2));


%Figures

figure,
semilogy(f,dsp/Fe);
hold on,
semilogy(f,Dsp_th,'r');
legend('DSP calculée', 'DSP théorique');
ylim([10^(-20), 1]);
