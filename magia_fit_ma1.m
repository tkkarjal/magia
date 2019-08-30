function [Vt,intercept,k] = magia_fit_ma1(pet_tacs,input,frames,start_time,end_time)
% Follows the strategy introduced in Ichise et al. 2002 JCBFM
% https://www.ncbi.nlm.nih.gov/pubmed/12368666
%
% Implemented by Tomi Karjalainen, August 30th 2019

% Make sure the PET and plasma radioactivities have the same units
max_cr = max(pet_tacs(:));
max_input = max(input(:,2));
if(max_cr < 500 && max_input > 500)
    input(:,2) = 0.001.*input(:,2);
elseif(max_cr > 500 && max_input < 500)
    input(:,2) = 1000.*input(:,2);
end

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


% Select indices that are used in fitting the line
if(end_time==0)
    end_time = frames(end,2);
end
k = frames(:,1) >= start_time & frames(:,2) <= end_time;

% Fit line
b1 = zeros(size(pet_tacs,2),1);
b2 = b1;
for i = 1:size(pet_tacs,2)
    M = [auc_input_interp(k) auc_pet(k,i)];
    p = M \ pet_tacs(k,i);
    b1(i) = p(1);
    b2(i) = p(2);
end

Vt = -b1./b2;
intercept = 1./b2;

end