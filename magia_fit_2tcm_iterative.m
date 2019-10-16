function [y,x_optim,e_min,vt] = magia_fit_2tcm_iterative(roi_tac,t_plasma,ca,cb,frames,varargin)

if(nargin==5)
    lb = [0 0.001 0.01 0 0];
    ub = [0.5 10 1 10 0.2];
elseif(nargin==6)
    lb = varargin{1};
    ub = [0.5 10 1 10 0.2];
elseif(nargin==7)
    lb = varargin{1};
    ub = varargin{2};
else
    error('Too many input parameters given.');
end

if(isempty(help('optimoptions')))
    opts = optimset('lsqcurvefit');
    opts = optimset(opts,'Display', 'off');
    opts = optimset(opts,'MaxIter',500);
else
    opts = optimoptions('lsqcurvefit');
    opts = optimoptions(opts,'Display', 'off');
    opts = optimoptions(opts,'MaxIter',500);
end

%% Exclude plasma and blood measurements before injection

pos_idx = t_plasma >= 0;
t_plasma = t_plasma(pos_idx);
ca = ca(pos_idx);
cb = cb(pos_idx);

%% Create an artificial data point at time zero

if(t_plasma(1) > 0)
    t_plasma = [0;t_plasma];
    ca = [0;ca];
    cb = [0;cb];
end

%% Fit the model to the data

t_pet = mean(frames,2);
if(size(roi_tac,2)~=1)
    roi_tac = roi_tac';
end

fun = @(x,t) spline(t_plasma,magia_2tcm_3(x,t,ca,cb),t_pet);

n = 25;
e_min = 1e10;
for i = 1:n
    x0 = unifrnd(lb,ub);
    [x,e] = lsqcurvefit(fun,x0,t_plasma,roi_tac,lb,ub,opts);
    if(e < e_min)
        e_min = e;
        x_optim = x;
    end
end

y = spline(t_plasma,magia_2tcm_3(x_optim,t_plasma,ca,cb),t_pet);
vt = x_optim(2)*(1+x_optim(4));

end