function value = magia_get_srtm_default_options(tracer,var)

if(iscell(tracer))
    tracer = tracer{1};
end

switch tracer
    case '[11c]carfentanil'
        switch var
            case 'lb'
                value = [0 0 0];
            case 'ub'
                value = [3 1 8];
            case 'theta3_lb'
                value = 0.06;
            case 'theta3_ub'
                value = 0.6;
            case 'nbases'
                value = 300;
        end
    case {'[11c]raclopride','[18f]cft'}
        switch var
            case 'lb'
                value = [0 0 0];
            case 'ub'
                value = [3 1 8];
            case 'theta3_lb'
                value = 0.082;
            case 'theta3_ub'
                value = 0.6;
            case 'nbases'
                value = 300;
        end
    case '[11c]madam'
        switch var
            case 'lb'
                value = [0 0 0];
            case 'ub'
                value = [3 1 8];
            case 'theta3_lb'
                value = 0.045;
            case 'theta3_ub'
                value = 0.6;
            case 'nbases'
                value = 300;
        end
    case '[11c]flb' % Based on https://www.ncbi.nlm.nih.gov/pubmed/11606887
        switch var
            case 'lb'
                value = [0 0 0];
            case 'ub'
                value = [3 1 15];
            case 'theta3_lb'
                value = 0.011;
            case 'theta3_ub'
                value = 0.12;
            case 'nbases'
                value = 300;
        end
    case {'[11c]pk11195','[11c]tmsx','[11c]ro15-4513'}
        switch var
            case 'lb'
                value = [0 0 0];
            case 'ub'
                value = [3 1 8];
            case 'theta3_lb'
                value = 0.06;
            case 'theta3_ub'
                value = 0.8;
            case 'nbases'
                value = 300;
        end
    otherwise
        error('Default SRTM options have not been specified for %s.',tracer);
        
end