%Création de la fonction PPM

function [sl]=ppm (bk,lenbk)

cpt=1;
for i=1:lenbk
    if bk(i)==0
        sl(cpt)=0;
        sl(cpt+1)=1;
        cpt=cpt+2;
    else
        sl(cpt)=1;
        sl(cpt+1)=0;
        cpt=cpt+2;
    end
end




