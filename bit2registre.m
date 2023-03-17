function [registre] = bit2registre(vect)

registre = struct('format',[],'adresse',[],'type',[],'nom',[],'altitude',[],'cprFlag',[],'latitude',[],'longitude',[]);
REF_LON = -0.606629; % Longitude de l'ENSEIRB-Matmeca
REF_LAT = 44.806884; % Latitude de l'ENSEIRB-Matmeca

% poly = [24 23 22 21 20 19 18 17 16 15 14 13 12 10 3 1];
poly = [1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 0 0 0 0 0 1 0 0 1];

crcGen = comm.CRCGenerator('Polynomial', poly, 'InitialConditions',0,'DirectMethod',true,'FinalXOR',0);
txSeq = crcGen(vect(1:96));
csDirect = txSeq(end-31:end-8);
res = isequal(csDirect,vect(end-23:end));

if res == 1 
 a=4;
 val = 0;        %Format
 for i=1:5
     bit = vect(i);
     val = val + bit*pow2(a);
     a = a-1;
 end
 registre.format = val;

 name = [];           %adresse
 oaciaddr = vect(9:32);
 len = length(oaciaddr);
%  for i=1:6:len
%     b = conversion(oaciaddr(i:i+5));
%     name = [name b];
%  end
a=23;
val = 0;
for i=1:len
    bit = oaciaddr(i);
    val = val + bit*pow2(a);
    a = a-1;
end
 
name = dec2hex(val);

 registre.adresse = char(name);


 a=4;        %FTC
 ftc = 0;
 for i=33:37
     bit = vect(i);
     ftc = ftc + bit*pow2(a);
     a = a-1;
 end
 registre.type = ftc;

 if ftc<=4 && ftc >=1
     % trame d'identification
     a = 41;
     b = 46;
     ident = zeros(1,9);
     for i=1:8
         id = conversion(vect(a:b));
         ident(i) = id;
         a = a+6;
         b = b+6;
     end
     registre.nom = char(ident);

 elseif ftc>=5 && ftc <=8
  %message position au sol
    % CPR Flag
     
    cpr = vect(54);
     registre.cprFlag = cpr;
     
    %récupération valeur latitude
     rala = cat(vect(46:52),vect(55:71));
     a = 16;
     LAT = 0;
     for i=55:71
         bit = rala(i);
         LAT = LAT + bit*pow2(a);
         a = a-1;
     end
     
     latitude = latcalc(LAT, cpr, REF_LAT);   %calcul de la latitude

     registre.latitude = latitude;
     
     %récupération valeur longitude
     a = 16;
     LONG = 0;
     for i=72:88
         bit = vect(i);
         LONG = LONG + bit*pow2(a);
         a = a-1;
     end
     
     cpr = vect(54);
     longitude = longcalc(LONG, cpr, latitude, REF_LON);
     
     
     registre.longitude = longitude;

 elseif ftc>=9 && ftc<=22
     %message position en l'air
     a=10;        %Altitude
     ra = vect(41:52);
     ra(8) = [];
     val = 0;
     for j=1:11
         bit = ra(j);
         val = val + bit*pow2(a);
         a = a-1;
     end
     
     %décodage altitude
     
     alt = 25*val-1000;
     registre.altitude = alt;
     
     % CPR Flag*
     
     cpr = vect(54);
     registre.cprFlag = cpr;
     
     
     %récupération valeur latitude
     a = 16;
     LAT = 0;
     for i=55:71
         bit = vect(i);
         LAT = LAT + bit*pow2(a);
         a = a-1;
     end
     
     latitude = latcalc(LAT, cpr, REF_LAT);   %calcul de la latitude

     registre.latitude = latitude;
     
     %récupération valeur longitude
     a = 16;
     LONG = 0;
     for i=72:88
         bit = vect(i);
         LONG = LONG + bit*pow2(a);
         a = a-1;
     end 
     
     longitude = longcalc(LONG, cpr, latitude, REF_LON);
     
     registre.longitude = longitude;

 end


else
 disp('CRC issue');
end





    