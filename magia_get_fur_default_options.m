function value = magia_get_fur_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[18f]fdg'
        switch var
            case 'start_time'
                value = 15;
            case 'ic'
                value = 0;
            case 'end_time'
                value = 0;
        end
    case '[18f]ftha'
        switch var
            case 'start_time'
                value = 10;
            case 'ic'
                value = 0;
            case 'end_time'
                value = 20;
        end
    otherwise
        error('Default FUR options have not been specified for %s.',tracer); 
end

end
