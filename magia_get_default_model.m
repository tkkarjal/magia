function model = magia_get_default_model(subject_id)

conn = aivo_connect();

tracer = aivo_get_info(subject_id,'tracer');
if(iscell(tracer))
    tracer = tracer{1};
end
switch tracer
    case {'[11c]carfentanil','[11c]raclopride','[11c]madam','[18f]cft','[11c]flb'}
        model = 'srtm';
    case '[18f]fdg'
        dyn = aivo_get_info(subject_id,'dynamic');
        if(iscell(dyn))
            dyn = dyn{1};
        end
        if(dyn)
            model = 'patlak';
        else
            model = 'fur';
        end
    case '[11c]pib'
        model = 'suvr';
    case '[18f]dopa'
        model = 'patlak_ref';
    case '[18f]fmpep-d2'
        model = '2tcm';
    otherwise
        model = 'unknown';
end

close(conn);
aivo_set_info(subject_id,'model',model);

end