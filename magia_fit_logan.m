function [Vt,intercept,X,Y,k] = magia_fit_logan(pet_tacs,input,frames,start_time,end_time)

% Calculate AUC of input and PET TAC
t_input = input(:,1);
Cp = input(:,2);
if(t_input(1) > 0)
    t_input = [0;t_input];
    Cp = [0;Cp];
end
auc_input = cumtrapz(t_input,Cp);
t_pet = mean(frames,2);
if(size(pet_tacs,1) ~= length(t_pet))
    pet_tacs = pet_tacs';
end
auc_pet = cumtrapz(t_pet,pet_tacs);

% Interpolate input AUC to PET sampling times
auc_input_interp = pchip(t_input,auc_input,t_pet);

% Logan: Divide the input and PET AUCs with PET radioactivities
X = repmat(auc_input_interp,[1 size(pet_tacs,2)])./pet_tacs;
Y = auc_pet./pet_tacs;

% Select indices that are used in fitting the line
if(end_time==0)
    end_time = frames(end,2);
end
k = frames(:,1) >= start_time & frames(:,2) <= end_time;

% Fit line
Vt = zeros(size(pet_tacs,2),1);
intercept = Vt;
I = ones(sum(k),1);
for i = 1:size(pet_tacs,2)
    M = [X(k,i) I];
    p = M \ Y(k,i);
    Vt(i) = p(1);
    intercept(i) = p(2);
end

end