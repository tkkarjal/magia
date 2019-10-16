function value = magia_get_logan_ref_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[11c]carfentanil'
        % Based on Hirvonen et al. EJNMMI 2009
        % https://doi.org/10.1007/s00259-008-0935-6
        switch var
            case 'start_time'
                value = 10;
            case 'end_time'
                value = 0;
            case 'refk2'
                value = 0.1237;
        end
    otherwise
        error('Default Logan_ref options have not been specified for the tracer %s.',tracer);
        
end

end