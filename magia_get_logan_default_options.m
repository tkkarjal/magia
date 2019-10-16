function value = magia_get_logan_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[18f]fmpep-d2'
        switch var
            case 'start_time'
                value = 41.5;
            case 'end_time'
                value = 0;
        end
    otherwise
        error('Default Logan options have not been specified for %s.',tracer);
        
end