clear;
close all;
clc;

%Initialisation
Fe=20e6;                        %Fréquence d'échantillonage
Ts=1e-6;                        %Période symbole
Fse=Ts*Fe;                      %Nombre d'échantillon
Nb=1000;                        %Nombre de points

% %Création de la fonction
lenbk=Nb;
p=[-0.5*ones(1,Fse/2),0.5*ones(1,Fse/2)];

%Création du bruit
sigA2=1;                        %Variance par symbole
eb_no_dB=0:10;                  %Variation du bruit de 1 dB
eb_no=10.^(eb_no_dB/10);        %Liste des bruits
Eg=sum(-p.*p);                   %Puissance du filtre
Puimoy=sigA2*Eg/Ts;             %Puissance moyenne
Eb=Eg;
sigma2=sigA2*Eb./(2*eb_no);
N0=zeros(1,11);
for i=1:length(eb_no)
    N0(i)=Eb.*(1/eb_no(i));
end

Pb=(1/2).*erfc(sqrt(eb_no));
TEB=zeros(size(eb_no));

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
        
        %% Ajout du bruit
        nl=(sqrt(sigma2(c))*(randn(size(slf))+1j*randn(size(slf))));
        yl=slf+nl;
        
        %% Convolution par p
        
        %On implémente le décalage dans le temps de p
        
        lenp=length(p);
        
        pa=p(end:-1:1);
        
        rl=conv(yl,pa);
        
        %% Echantillonnage
        
        rm=zeros(1,lenbk);
        k=1;
        for i=Fse:Fse:length(rl)-Fse
            rm(k)=rl(i);
            k=k+1;
        end
        
        %% Décision
        
        
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

end
%%  Figure

figure,
plot(bk(1:20),'-');
title('Représenation des symboles émis');

figure,
plot(bkd(1:20),'-');
title('Représenation des symboles reçus');
figure,
plot(sl(1:20),'*');

figure,
plot(rl(1:200),'*');

% %Taux erreur binaire théorique
figure,
semilogy(eb_no_dB, Pb);

hold on,
semilogy(eb_no_dB,TEB),
title('Taux de l erreur binaire en fonction de eb_n0_dB')
xlabel('Rapport Eb/N0 en dB')
ylabel('TEB sans unité')
legend({'Proba erreur théorique','TEB simulé'},'Location','southwest')