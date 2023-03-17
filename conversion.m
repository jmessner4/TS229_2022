function [res] = conversion(vect)

a=5;
val = 0;
for i=1:6
    bit = vect(i);
    val = val + bit*pow2(a);
    a = a-1;
end

if val>47
    res = char(val);
elseif val == 32
        res = ' ';
else
    val = val + 64;
    res = char(val);
end
