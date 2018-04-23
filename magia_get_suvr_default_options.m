function value = magia_get_suvr_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[11c]pib'
        switch var
            case 'start_time'
                value = 60;
            case 'end_time'
                value = 90;
        end
    otherwise
        switch var
            case 'start_time'
                value = 0;
            case 'end_time'
                value = 0;
        end
end

end