clear;
close all;
clc;

%Initialisation
Fe=20e6;                        %Fréquence d'échantillonage
Ts=1e-6;                        %Période symbole
Te=1/Fe;
Fse=Ts*Fe;                      %Nombre d'échantillon
Nb=1000;                         %Nombre de points

% %Création de la fonction
lenbk=Nb;
p=[-0.5*ones(1,Fse/2),0.5*ones(1,Fse/2)];

%Création du bruit
sigA2=1;                        %Variance par symbole
eb_no_dB=0:10;                  %Variation du bruit de 1 dB
eb_no=10.^(eb_no_dB/10);        %Liste des bruits
Eg=sum(p.*p);                   %Puissance du filtre
Puimoy=sigA2*Eg/Ts;             %Puissance moyenne
Eb=Eg;
sigma2=sigA2*Eb./(2*eb_no);
N0=zeros(1,11);
for i=1:length(eb_no)
    N0(i)=Eb.*(1/eb_no(i));
end

Pb=(1/2).*erfc(sqrt(eb_no));
TEB=zeros(size(eb_no));


%Définition du préambule
cd1=ones(1,Fse/2);
cd0=zeros(1,Fse/2);
sp=[cd1 cd0 cd1 cd0 cd0 cd0 cd0 cd1 cd0 cd1 cd0 cd0 cd0 cd0 cd0 cd0];

for c=1:length(TEB)
    bk=randi([0,1],1,Nb);
    error_cnt=0;
    bit_cnt=0;
    while error_cnt<100
        %% PPM
        sl=PPM(bk,lenbk);
        lens=length(sl);
        %Suréchantillonnage
        slsur=upsample(sl,Fse/2);
        lenss=length(slsur);
        
        filtre=ones(1,Fse/2);
        slf=conv(slsur,filtre);
        
        %On ajoute le préambule
        slp=horzcat(sp, slf);
        
        %Ajout de delta_t
        delta_t=randi([0,100],1,1);
        delai=zeros(delta_t,1);
        delai=transpose(delta_t);
        slsyn=[delai slp];
        
        %Création de y
        
        delta_f=randi([-1000 1000],1,1);

        lensl=length(slsyn);
        y=zeros(1,lensl);
        
        t=1:1:lensl;

 
        y=slsyn.*exp(-1j*2*pi*delta_t*t);

        %% Convolution par p
        %On implémente le décalage dans le temps de p
        lenp=length(p);
        
        pa=p(end:-1:1);
        
        rl=conv(y,pa);
        
        %Synchronisation
        rlca=rl.*rl;
        deltatest=synchronisation(rlca,sp);

        %% Echantillonnage
        rm=zeros(1,lenbk);
        k=1;
        for i=Fse:Fse:length(rl)-Fse
            rm(k)=rl(i);
            k=k+1;
        end
        
        %% Décision
        bkd=zeros(1,lenbk);
        
        rmdeci=real(rm);
        tmp=rmdeci<0;
        bkd=double(tmp);

        for n=1:length(bk)
            if bk(n)~=bkd(n)
                error_cnt = error_cnt+1; % incrémenter le compteur d ; erreurs
            end
            bit_cnt = bit_cnt + 1; % incrémenter le compteurde bits envoyés 
        end
    end
    TEB (c) = error_cnt/bit_cnt;
    diffdelta=deltatest(1)/delta_t;
end


figure,
semilogy(eb_no_dB, Pb);

hold on,
semilogy(eb_no_dB,TEB),
title('Taux de l erreur binaire en fonction de eb_n0_dB')
xlabel('Rapport Eb/N0 en dB')
ylabel('TEB sans unité')
legend({'Proba erreur théorique','TEB simulé'},'Location','southwest')
