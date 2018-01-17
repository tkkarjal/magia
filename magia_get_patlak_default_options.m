function value = magia_get_patlak_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[18f]fdg'
        switch var
            case 'start_time'
                value = 15;
            case 'end_frame'
                value = 0;
        end
    otherwise
        error('Default Patlak options have not been specified for %s.',tracer);
        
end