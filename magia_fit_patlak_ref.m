function [Ki_ref,intercept,x,Y,k] = magia_fit_patlak_ref(ref_tac,tacs,frames,start_time,end_time)

if(~end_time)
    end_time = frames(end,2);
end

t = mean(frames,2);

if(size(tacs,2) ~= size(frames,1))
    tacs = tacs';
end

k1 = find(frames(:,1) >= start_time);
k2 = find(frames(:,2) <= end_time);
k = intersect(k1,k2);

Y = tacs./repmat(ref_tac',[size(tacs,1) 1]);

X = cumtrapz(t,ref_tac);
x = X./ref_tac;
xk = x(k);

Yk = Y(:,k);
B = zeros(size(tacs,1),2);

for i = 1:size(tacs,1)
    y = Yk(i,:)';
    B(i,:) = [xk ones(size(xk))] \ y;
end

Ki_ref = B(:,1);
intercept = B(:,2);

end 
