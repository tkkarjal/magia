function specs = aivo_read_specs(image_id)
% Retrieves the Magia-specs from AIVO

%% specs.study

specs.study.tracer = lower(char(aivo_get_info(image_id,'tracer')));
specs.study.frames = parse_frames_string(char(aivo_get_info(image_id,'frames')));
specs.study.weight = aivo_get_info(image_id,'weight');
specs.study.dose = aivo_get_info(image_id,'dose');
specs.study.scanner = lower(char(aivo_get_info(image_id,'scanner')));

%% specs.magia

specs.magia.model = char(aivo_get_info(image_id,'model'));
specs.magia.input_type = char(aivo_get_info(image_id,'input_type'));
specs.magia.roi_type = char(aivo_get_info(image_id,'roi_type'));
specs.magia.dc = aivo_get_info(image_id,'dc');
specs.magia.rc = aivo_get_info(image_id,'rc');
specs.magia.fwhm_pre = aivo_get_info(image_id,'fwhm_pre');
specs.magia.fwhm_post = aivo_get_info(image_id,'fwhm_post');
specs.magia.cpi = aivo_get_info(image_id,'cpi');
specs.magia.cut_time = aivo_get_info(image_id,'cut_time');
specs.magia.mri_code = char(aivo_get_info(image_id,'mri'));
specs.magia.norm_method = char(aivo_get_info(image_id,'norm_method'));
specs.magia.roi_set = char(aivo_get_info(image_id,'norm_method'));
specs.magia.mni_atlas = char(aivo_get_info(image_id,'norm_method'));
specs.magia.classfile = char(aivo_get_info(image_id,'norm_method'));

end