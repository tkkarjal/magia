function [Ki,V0,x,y,k,yy] = magia_fit_patlak_ref(input,Cr,pet_frames,startTime,cutTime)

if(~cutTime)
    cutTime = pet_frames(end,2);
end

t = mean(pet_frames,2);

if(size(Cr,1)==1)
    Cr = Cr';
end

k1 = find(pet_frames(:,1) >= startTime);
k2 = find(pet_frames(:,2) <= cutTime);
k = intersect(k1,k2);

y = Cr./input;

X = cumtrapz(t,input);
x = X./input;

% y = V0 + Ki*x

B = polyfit(x(k),y(k),1);

Ki = B(1);
V0 = B(2);

yy = V0 + Ki*x;

end 
