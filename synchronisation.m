%Création de la fonction synchronisation

function[delta_test]=synchronisation(rl,sp)


%Calcul des intégrales


IntSp=sum(abs(sp).^2);
SizeRl=length(rl);
SizeSp=length(sp);
SizeInt=SizeRl-SizeSp;
delta_test=0;
p=[];
for i=1:SizeInt
    IntRl=sum(abs(rl(i:i+SizeSp-1).^2));
    IntRlSp=sum(rl(i:i+SizeSp-1).*conj(sp));
    p=horzcat(p,IntRlSp/(sqrt(IntSp).*sqrt(IntRl)));
    delta_test = max(p);
end


