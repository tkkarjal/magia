function value = magia_get_default_specs(field_name,tracer)
% Specifies default options for Magia processing. Some of the defaults are
% tracer-dependent. Not all fields have a default. For example, the fields
% template and mni_atlas_dir require specification of full paths, which
% makes them site-dependent fields. The field classfile, on the other hand,
% is dependent on the scanner, again making it site-dependent.

switch lower(field_name)
    case 'rc'
        value = 0;
    case 'fwhm_pre'
        switch tracer
            case '[18f]fmpep-d2'
                value = 8;
            otherwise
                value = 4;
        end
    case 'fwhm_post'
        value = 6;
    case 'fwhm_roi'
        value = 0;
    case 'cpi'
        value = 1;
    case 'cut_time'
        value = 0;
    case 'norm_method'
        value = 'mri';
    case 'roi_set'
        value = 'tracer_default';
    case 'roi_type'
        value = 'freesurfer';
    case 'mc_ref_frame'
        switch tracer
            case '[11c]pk11195'
                value = 10;
            otherwise
                value = 0;
        end
    case 'mc_fwhm'
        switch tracer
            case '[11c]pk11195'
                value = 2;
            otherwise
                value = 7;
        end
    case 'mc_rtm'
        switch tracer
            case '[11c]pk11195'
                value = 0;
            otherwise
                value = 1;
        end
    case 'mc_sep'
        switch tracer
            case '[11c]pk11195'
                value = 1;
            otherwise
                value = 2;
        end
    case 'mc_excluded_frames'
        value = [];
    otherwise
        error('No default Magia-specs have been specified for the field %s.',lower(field_name));
end

end