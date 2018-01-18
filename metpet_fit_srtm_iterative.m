function [y,x,e] = metpet_fit_srtm_iterative(roi_tac,ref_tac,times,varargin)
% inputs:
% roi_tac = the model is fitted to this tac
% ref_tac = the reference tac that is used to fit the model
% times  = frame time info (start and end times in minutes)
% x0 = [R10 k20 BP0]', initial guesses for the model parameters
%
% outputs:
% y = fit
% x = [R1 k2 BP]', estimated parameters
% e = sum of squared errors

if(nargin==3)
    x0 = [1 0.1 1];
    lb = [0 0 0];
    ub = [3 1 7];
elseif(nargin==4)
    x0 = varargin{1};
    lb = [0 0 0];
    ub = [3 1 7];
elseif(nargin==5)
    x0 = varargin{1};
    lb = varargin{2};
    ub = [3 1 7];
else
    x0 = varargin{1};
    lb = varargin{2};
    ub = varargin{3};
end 

if(isempty(help('optimoptions')))
    opts = optimset('lsqcurvefit');
    opts = optimset(opts,'Display', 'off');
    opts = optimset(opts,'MaxIter',500);
    opts = optimset(opts,'Jacobian', 'on');
else
    opts = optimoptions('lsqcurvefit');
    opts = optimoptions(opts,'Display', 'off');
    opts = optimoptions(opts,'MaxIter',500);
    opts = optimoptions(opts,'Jacobian', 'on');
end

t = mean(times,2);

dt = [t(1); t(2:end)-t(1:end-1)]; % the distance between two consequtive mid-frame time points, NOTE often differs from frame duration
cri = cumtrapz(t,ref_tac);
M = length(t);

fun = @(x,t) simSRTM_1_0_0(x,t,ref_tac,cri,dt,M);
[x,e] = lsqcurvefit(fun,x0,t,roi_tac,lb,ub,opts);
y = simSRTM_1_0_0(x,t,ref_tac,cri,dt,M);

end