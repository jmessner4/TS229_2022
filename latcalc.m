function lat = latcalc(LAT,i,latref)

Nz = 15;
Nb = 17;

Dlat = 360/(4*Nz-i);

j = floor(latref/Dlat) + floor(1/2 + (latref - (Dlat*floor(latref/Dlat)))/Dlat - (LAT/(2^Nb)));

lat = Dlat*(j + (LAT/(2^Nb)));