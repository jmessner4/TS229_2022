clear;
close all;
clc;

%Initialisation

Nb=88;                          %taille paquet d'information binaire
Fe=20e6;                        %Fréquence d'échantillonage
Ts=1e-6;                        %Période symbole
Fse=Ts*Fe;                      %Nombre d'échantillon
polynome=[1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];
poly='z^24+z^23+z^22+z^21+z^20+z^19+z^18+z^17+z^16+z^15+z^14+z^13+z^12+z^10+z^3+1';


%crcGen = comm.CRCGenerator('Polynomial', poly, 'InitialConditions',0,'DirectMethod',true,'FinalXOR',0);

codeur = comm.CRCGenerator(poly);
decodeur = comm.CRCDetector(poly);

%Initialisation
Fe=20e6;                        %Fréquence d'échantillonage
Ts=1e-6;                        %Période symbole
Fse=Ts*Fe;                      %Nombre d'échantillon
Nb=1000;                        %Nombre de points

% %Création de la fonction
lenbk=Nb;
p=[-0.5*ones(Fse/2,1);0.5*ones(Fse/2,1)];

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

for c=1:length(TEB)
    bk=randi([0,1],1,Nb);
    error_cnt=0;
    bit_cnt=0;
    %while error_cnt<100
        %% PPM
        sl=PPM(bk,lenbk);
        slc=codeur(transpose(sl));
        lens=length(slc);
        %Suréchantillonnage
        slsur=upsample(slc,Fse/2);
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
        
        bkd=zeros(1,lenbk);
        
        rmdeci=real(rm)+imag(rm);
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
    %Décodeur CRC
    [msg_crc,err_crc] = decodeur(slc); % Detect CRC errors
    err = transpose(err_crc) ;
    msg = transpose(msg_crc) ;
    if err ==0 
        fprintf ("le message est intègre\r") 
    else 
        fprintf ("le message n’est pas intègre\r")

    end
   