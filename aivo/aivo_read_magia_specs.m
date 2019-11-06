function specs = aivo_read_magia_specs(image_id)

%%% specs.study
% mandatory
specs.study.tracer = char(aivo_get_info(image_id,'tracer'));
if(strcmp(specs.study.tracer,'null'))
    error('%s: The tracer has not been specified. Please use aivo_set_info to specify the tracer.',image_id);
end
specs.study.frames = parse_frames_string(char(aivo_get_info(image_id,'frames')));
if(strcmp(specs.study.frames,'null'))
    error('%s: The frames have not been specified. Please use aivo_set_info to specify the frames',image_id);
end
% optional
specs.study.weight = aivo_get_info(image_id,'weight');
specs.study.dose = aivo_get_info(image_id,'dose');
specs.study.scanner = char(aivo_get_info(image_id,'scanner'));
specs.study.mri_code = char(aivo_get_info(image_id,'mri_code'));
specs.study.glucose = aivo_get_info(image_id,'glucose');


%%% specs.magia
% mandatory
specs.magia.model = char(aivo_get_info(image_id,'model'));
if(strcmp(specs.magia.model,'null'))
    error('%s: The model has not been specified. Please use aivo_set_info to specify the model.',image_id);
end
specs.magia.input_type = char(aivo_get_info(image_id,'input_type'));
if(strcmp(specs.magia.input_type,'null'))
    error('%s: The field ''input_type'' has not been specified. Please use aivo_set_info to specify the ''input_type'' either as ''ref'', ''plasma'', ''plasma&blood'', or ''sca_ref''. ',image_id);
end
specs.magia.roi_type = char(aivo_get_info(image_id,'roi_type'));
if(strcmp(specs.magia.roi_type,'null'))
    error('%s: The field ''magia.roi_type'' has not been specified. Please use aivo_set_info to specify the field either as ''freesurfer'' or ''atlas''.',image_id);
end
specs.magia.dc = aivo_get_info(image_id,'dc');
if(strcmp(specs.magia.dc,'null'))
    error('%s: The field ''magia.dc'' has not been specified. Please use aivo_set_info to specify the field either as 1 (decay-corrected to injection time) or 0 (not decay-corrected to injection time).',image_id);
end
specs.magia.rc = aivo_get_info(image_id,'rc');

specs.magia.fwhm_pre = aivo_get_info(image_id,'fwhm_pre');
specs.magia.fwhm_post = aivo_get_info(image_id,'fwhm_post');
specs.magia.fwhm_roi = aivo_get_info(image_id,'fwhm_roi');
specs.magia.cpi = aivo_get_info(image_id,'cpi');
if(strcmp(specs.magia.cpi,'null'))
    error('%s: The field ''magia.cpi'' has not been specified. Please use aivo_set_info to specify the field either as 1 (calculate parametric images) or 0 (do not calculate parametric images).',image_id);
end

specs.magia.cut_time = aivo_get_info(image_id,'cut_time');
specs.magia.gu = aivo_get_info(image_id,'gu');

% optional

if(specs.magia.cpi)
    specs.magia.norm_method = char(aivo_get_info(image_id,'norm_method'));
    if(strcmp(specs.magia.norm_method,'pet'))
        specs.magia.template = char(aivo_get_info(image_id,'template'));
    end
end

if(strcmp(specs.magia.roi_type,'freesurfer'))
    specs.magia.roi_set = char(aivo_get_info(image_id,'roi_set'));
elseif(strcmp(specs.magia.roi_type,'atlas'))
    specs.magia.mni_roi_mask_dir = char(aivo_get_info(image_id,'mni_roi_mask_dir'));
end

if(strcmp(specs.magia.input_type,'sca_ref'))
    specs.magia.classfile = char(aivo_get_info(image_id,'classfile'));
end

end