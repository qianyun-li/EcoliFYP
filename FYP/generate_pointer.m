% This code draws a cirlce using Bresenham circle algorithm.

function pointer = generate_pointer(c,r)
a = c(1);
b = c(2);
inc = 1;
pointer = NaN(32,32);
pointer(a-1:a+1,b) = 1;
pointer(a,b-1:b+1) = 1;

x = 0;
y = r;
d= 3-2*r;
while(x < y)
    for i= -1:2:1
        for j= -1:2:1
            pointer(a+i*x,b+j*y) = 1;
            pointer(a+i*y,b+j*x) = 1;
        end
    end
    
    if d>=0
        d = d +4*(x-y)+10;
        x = x + 1/inc;
        y = y - 1/inc;
    else
        d = d + 4*x +6;
        x = x+1/inc;
    end
end

pointer = round(pointer);