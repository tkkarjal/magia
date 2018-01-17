function [Ki,V0,x,y,k,yy] = metpet_fit_patlak(plasmadata,Cr,pet_frames,startTime,cutFrame)

k1 = find(pet_frames(:,2) > startTime);
k2 = find(1:length(Cr)<=cutFrame);
k = intersect(k1,k2);

max_cr = max(Cr(:));
max_input = max(plasmadata(:,2));

if(max_cr < 500 && max_input > 500)
    plasmadata(:,2) = 0.001.*plasmadata(:,2);
elseif(max_cr > 500 && max_input < 500)
    plasmadata(:,2) = 1000.*plasmadata(:,2);
end

Cp = plasmadata(:,2);
t_plasma = plasmadata(:,1);
P = pchip(t_plasma,Cp);
t = mean(pet_frames,2);
Cp_interpolated = ppval(P,t);

if(size(Cr,1)==1)
    Cr = Cr';
end

y = Cr(k)./Cp_interpolated(k);

X = cumtrapz(t_plasma,Cp);
PI = pchip(t_plasma,X);
x = ppval(PI,t(k))./Cp_interpolated(k);

% y = V0 + Ki*x

B = polyfit(x,y,1);

Ki = B(1);
V0 = B(2);

yy = V0 + Ki*x;

end 
