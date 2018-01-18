function [CT, DT] = simSRTM_1_0_0(x,t,cr,cri,dt,nr)
%% simESRTM 1.0.2 (c) Turku PET Centre 2009
% CT = simESRTM(T,CR,nr,R1,k2,BP)
% T  = mid times (length(T)=nr)
% CR = reference region TAC (length(CR)=nr)
% nr = number of time points
% R1 = ratio K1/K1'
% k2 = k2 apparent
% BP = vector of BP in each mid time (length(BP)=nr)

%changes 22.8.2009, JP:
%preallocated CT array, cri & dt passed directly
%changes 18.11.2009, JP:
%added calculation of partial derivatives with respect to parameters:
%needed for calculating statistical properties /
%when using lsqcurvefit + other optimizers
%combined dCTdBP vector needs to be split into correct parts afterwards

R1 = x(1);
k2 = x(2);
BP = x(3);

%% Calculate Tissue simulation

CT = zeros(size(cr));
dCTdk2 = zeros(size(cr));
dCTdBP = zeros(size(cr));

h = k2/(1+BP);
h2 = 0.5*h;
f = R1*cr(1) + k2*cri(1);
g = 1 + dt(1)*h2;
CT(1)   = f/g;
F = cri(1);
G = dt(1)*h2/k2;
dCTdk2(1) = (F*g - f*G)/(g*g);
%if (nargout > 1), %for jacobian
%dCTdk2(1)  = cri(1) - (h/k2)*(dt(1)*(CT(1))*0.5 );
%end;
cti_last= dt(1)*CT(1)/2;

for i=2:nr
    h3 = 0.5*dt(i);
    a = cti_last + h3*CT(i-1);
    f = R1*cr(i) + k2*cri(i) - h*a;
    g = 1+dt(i)*h2;
    h4 = g*g;
    CT(i) = f/g;
    %if (nargout > 1), %for jacobian
    %dCTdk2(i) = cri(i) - (1/(1+BP))*( cti_last + dt(i)*(CT(i-1)+CT(i))/2 );
    
    F = cri(i) - (h/k2)*a; % derivative of f with respect to k2
    G = dt(i)*h2/k2; % derivative of g with respect to k2
    dCTdk2(i) = (F*g - f*G)/h4;
    
    b = (1+BP)^2;
    h5 = k2/b;
    F = h5*a; % derivative of f with respect to BP
    G = -h3*h5; % derivative of g with respect to BP
    dCTdBP(i) = (F*g - f*G)/h4;
    %end;
    cti_last = cti_last + h3*(CT(i)+CT(i-1));
end

%if (nargout > 1)
dCTdR1 = cr;
%dCTdBPcmbd = h*(cri - dCTdk2); %combined dCTdBP, derived from the original equation with integrals
%     CT_2 = R1.*cr + k2.*cri - k2.*(cri-dCTdk2); %test for partial derivatives
%     plot(t,CT,'.',t,CT_2,'-o')
%end

%DT = [dCTdR1' dCTdk2' dCTdBPcmbd'];
DT = [dCTdR1' dCTdk2' dCTdBP'];

end
