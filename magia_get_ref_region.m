function ref_region = magia_get_ref_region(tracer)

switch tracer
    case {'[11c]carfentanil', '[18f]dopa'}
        ref_region.label = 'OC';
        ref_region.codes = [1011 2011];
    case {'[11c]raclopride','[11c]madam','[18f]spa-rq','[11c]pib','[11c]pbr28','[18f]cft','[11c]flb','[18f]fdg','[11c]ro15-4513','[11c]pk11195'}
        ref_region.label = 'CER';
        ref_region.codes = [8 47];
    case {'[11c]tmsx'}
        ref_region.label = 'CAU';
        ref_region.codes = [11 50];
    case '[18f]fmpep-d2'
        ref_region.label = 'WM';
        ref_region.codes = [2 41];
    otherwise
        ref_region = '';
end

end
