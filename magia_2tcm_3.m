function cpet = magia_2tcm_3(x,t,ca,cb)
%% Simulates two-tissue compartmental model curves.
%
% Inputs:
%
% x              = 5 x 1 vector, where the first value represents k1, the
%                  second value represents k1/k2, the third value
%                  represents k3, the fourth value represents k3/k4, and
%                  the fourth value represents vb (vascular volume
%                  fraction).
% plasmadata     = N x 2 matrix, where the first column represents time
%                  points and the second columns represents plasma activity.
%
% Derivation of the iterative method to calculate the curves:
% http://www.turkupetcentre.net/reports/tpcmod0001.pdf
%
% Source code in C:
% http://www.turkupetcentre.net/tpcclib-doc/v1/libtpcmodel_8h.html#a34a9c4949a46d0323695b9e86a5491a0

k1 = x(1);
k2 = x(1)/x(2);
k3 = x(3);
k4 = x(3)/x(4);
vb = x(5);

N = size(t,1);

%% Calculate curves

t_last = 0;
if(t(1) < t_last)
    t_last = t(1);
end

cai = 0;
ca_last = 0;
ct1_last = 0;
ct2_last = 0;
ct1i_last = 0;
ct2i_last = 0;

cpet = zeros(N,1);

for i = 1:N
    
    dt2=0.5*(t(i)-t_last);
    
    % Arterial integral
    cai = cai + (ca(i)+ca_last)*dt2;
    
    % Partial results
    b = ct1i_last + dt2*ct1_last;
    c = ct2i_last + dt2*ct2_last;
    z = 1 + k4*dt2;
    
    % 1st tissue compartment and its integral
    ct1 = (k1*z*cai + (k3*k4*dt2 - (k2+k3)*z)*b + k4*c) / (z*(1 + dt2*(k2+k3)) - k3*k4*dt2*dt2);
    ct1i = ct1i_last + dt2*(ct1_last+ct1);
    
    % 2nd tissue compartment and its integral
    ct2 = (k3*ct1i - k4*c) / z;
    ct2i = ct2i_last + dt2*(ct2_last + ct2);
    
    % Save the results into arrays
    cpet(i) = vb*cb(i) + (1-vb)*(ct1 + ct2);
   
    if(i~=N)
        % Prepare for the next loop
        t_last=t(i); ca_last=ca(i);
        ct1_last=ct1; ct1i_last=ct1i;
        ct2_last=ct2; ct2i_last=ct2i;
    end
    
end

end