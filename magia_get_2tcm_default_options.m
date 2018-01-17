function value = magia_get_2tcm_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[18f]fmpep-d2'
        switch var
            case 'k1_lb'
                value = 0;
            case 'k1k2_lb'
                value = 0.001;
            case 'k3_lb'
                value = 0.01;
            case 'k3k4_lb'
                value = 0;
            case 'vb_lb'
                value = 0;
            case 'k1_ub'
                value = 0.5;
            case 'k1k2_ub'
                value = 10;
            case 'k3_ub'
                value = 1;
            case 'k3k4_ub'
                value = 10;
            case 'vb_ub'
                value = 0.2;
        end
    otherwise
        error('Default 2TCM options have not been specified for %s.',tracer);
end

end