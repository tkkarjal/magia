function x0 = metpet_random_init_srtm(lb,ub)

if(size(ub,1)==1)
    ub = ub';
end

if(size(lb,1)==1)
    lb = lb';
end

d = ub - lb;
if(sum(d<=0))
    error('The upper boundary must be higher than the lower boundary.');
end

x0 = lb + d.*rand(3,1);

end