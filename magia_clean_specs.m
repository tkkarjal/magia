function specs = magia_clean_specs(specs)

magia_specs = specs.magia;

%% If the model is SUV, input is not needed

if(strcmp(magia_specs.model,'suv'))
    magia_specs.input_type = 'no_input';
end

%% If the input_type is not classfile, then the field classfile is not needed and can be removed

if(isfield(magia_specs,'classfile') && isempty(magia_specs.classfile))
    if(~strcmp(magia_specs.input_type,'sca_ref'))
        if(isfield(magia_specs,'classfile'))
            magia_specs = rmfield(magia_specs,'classfile');
        end
    end
end

%% If the norm_method is 'mri', then the field template is not needed and can be removed

if(strcmp(magia_specs.norm_method,'mri'))
    if(isfield(magia_specs,'template'))
        magia_specs = rmfield(magia_specs,'template');
    end
end

%% Remove fields depending on the roi_type

switch magia_specs.roi_type
    case 'freesurfer'
        if(isfield(magia_specs,'mni_roi_mask_dir'))
            magia_specs = rmfield(magia_specs,'mni_roi_mask_dir');
        end
    case 'atlas'
        if(isfield(magia_specs,'roi_set'))
            magia_specs = rmfield(magia_specs,'roi_set');
        end
end

%% Clean mc_excluded_frames

if(strcmp(magia_specs.mc_excluded_frames,'null'))
    magia_specs.mc_excluded_frames = [];
else
    magia_specs.mc_excluded_frames = magia_parse_excluded_frames(magia_specs.mc_excluded_frames);
end

%% If GU = 1 but glucose is unspecified then change GU = 0 and continue

if(magia_specs.gu)
    if(isfield(specs.study,'glucose') && isnan(specs.study.glucose))
        magia_specs.gu = 0;
    end
end

specs.magia = magia_specs;


end