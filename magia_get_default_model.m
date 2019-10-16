function model = magia_get_default_model(tracer)

switch tracer
    case {'[11c]carfentanil','[11c]raclopride','[11c]madam','[18f]cft','[11c]flb','[11c]pk11195','[11c]tmsx'}
        model = 'srtm';
    case '[18f]fdg'
        model = 'patlak';
    case '[11c]pib'
        model = 'suvr';
    case '[18f]dopa'
        model = 'patlak_ref';
    case '[18f]fmpep-d2'
        model = 'logan';
    otherwise
        warning('No default model has been defined for the tracer %s',tracer);
end

end
