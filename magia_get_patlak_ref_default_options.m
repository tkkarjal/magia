function value = magia_get_patlak_ref_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[18f]dopa'
        switch var
            case 'start_time'
                value = 15;
            case 'cut_time'
                value = 0;
            case 'filter_size'
                value = 0;
        end
    otherwise
        error('Default Patlak_ref options have not been specified for %s.',tracer);
        
end