function roi_set = get_tracer_default_roi_set(tracer)

switch lower(tracer)
    case {'[11c]carfentanil','[11c]pbr28'}
        roi_set = 'rs1';
    case '[18f]fmpep-d2'
        roi_set = 'rs2';
    case {'[11c]raclopride','[18f]cft','[18f]dopa'}
        roi_set = 'rs3';
    case '[11c]madam'
        roi_set = 'rs4';
    case {'[18f]fdg','[18f]ftha'}
        roi_set = 'rs5';
    case {'[11c]pib','[11c]pk11195'}
        roi_set = 'rs6';
    case '[11c]flb'
        roi_set = 'rs7';
    otherwise
        error('No default roi_set has been defined for %s.\n',tracer);
end

end
