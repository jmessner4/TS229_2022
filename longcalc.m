function long = longcalc(LONG,i,lat,longref)

Nb = 17;
Dlon = 0;

if (cprNL(lat)-i) > 0
    Dlon = 360/(cprNL(lat)-i);
elseif (cprNL(lat)-i) == 0
    Dlon = 360;
end

m = floor(longref/Dlon) + floor(1/2 + ((longref - Dlon*floor(longref/Dlon))/Dlon - (LONG/(2^Nb))));

long = Dlon*(m + (LONG/(2^Nb)));