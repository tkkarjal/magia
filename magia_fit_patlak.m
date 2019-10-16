function [Ki,intercept,x,Y,k] = magia_fit_patlak(plasmadata,tacs,frames,start_time,end_frame)
% Fits Patlak to the given time-activity curves (tacs).
%
% Inputs:
% 
% plasmadata = N_plasma x 2 matrix, where N_plasma is the number of time-
%              points
% tacs       = N_frames x N_tacs matrix, where N_frames is the number of
%              frames and N_tacs is the number of time-activity curves
% frames     = N_frames x 2, where N_frames is the number of frames

if(end_frame == 0)
    end_frame = size(frames,1);
end
if(size(tacs,2) ~= size(frames,1))
    tacs = tacs';
end

k1 = find(frames(:,2) > start_time);
k2 = find(1:size(frames,1) <= end_frame);
k = intersect(k1,k2);

Cp = plasmadata(:,2);
t_plasma = plasmadata(:,1);
P = pchip(t_plasma,Cp);
t = mean(frames,2);
Cp_interp = ppval(P,t);

Y = tacs./ repmat(Cp_interp',[size(tacs,1) 1]);
Yk = Y(:,k);

auc_plasma = cumtrapz(t_plasma,Cp);
auc_plasma_interp = pchip(t_plasma,auc_plasma,t);
x = auc_plasma_interp ./ Cp_interp;
xk = x(k);

B = zeros(size(tacs,1),2);

for i = 1:size(tacs,1)
    y = Yk(i,:)';
    B(i,:) = [xk ones(size(xk))] \ y;
end

Ki = B(:,1);
intercept = B(:,2);

end