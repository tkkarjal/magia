function specs = aivo_read_magia_specs(image_id)

%%% specs.study
% mandatory
specs.study.tracer = char(aivo_get_info(image_id,'tracer'));
specs.study.frames = parse_frames_string(char(aivo_get_info(image_id,'frames')));
% optional
specs.study.weight = aivo_get_info(image_id,'weight');
specs.study.dose = aivo_get_info(image_id,'dose');
specs.study.scanner = char(aivo_get_info(image_id,'scanner'));
specs.study.mri_code = char(aivo_get_info(image_id,'mri'));


%%% specs.magia
% mandatory
specs.magia.model = char(aivo_get_info(image_id,'model'));
try
specs.magia.input_type = char(aivo_get_info(image_id,'input_type'));
specs.magia.roi_type = char(aivo_get_info(image_id,'roi_type'));
catch
    
end
specs.magia.dc = aivo_get_info(image_id,'dc');
specs.magia.rc = aivo_get_info(image_id,'rc');
try
specs.magia.fwhm_pre = aivo_get_info(image_id,'fwhm_pre');
specs.magia.fwhm_post = aivo_get_info(image_id,'fwhm_post');
specs.magia.cpi = aivo_get_info(image_id,'cpi');
catch
end
specs.magia.cut_time = aivo_get_info(image_id,'cut_time');
% optional
try
specs.magia.norm_method = char(aivo_get_info(image_id,'norm_method'));
catch
end
specs.magia.roi_set = char(aivo_get_info(image_id,'roi_set'));
try
specs.magia.mni_atlas = char(aivo_get_info(image_id,'mni_atlas'));
specs.magia.classfile = char(aivo_get_info(image_id,'classfile'));
catch
end

end