function modeling_options = aivo_read_modeling_options(subject_id)

model = aivo_get_info(subject_id,'model');
if(iscell(model))
    model = model{1};
end

if(strcmp(model,'null'))
    model = magia_get_default_model(subject_id);
end

cut_time = aivo_get_info(subject_id,'cut_time');
if(iscell(cut_time))
    cut_time = cut_time{1};
end

switch model
    case 'srtm'
        modeling_options = aivo_read_srtm_modeling_options(subject_id);
    case 'patlak'
        modeling_options = aivo_read_patlak_modeling_options(subject_id);
    case 'patlak_ref'
        modeling_options = aivo_read_patlak_ref_modeling_options(subject_id);
    case 'two_tcm'
        modeling_options = aivo_read_2tcm_modeling_options(subject_id);
    case 'fur'
        modeling_options = aivo_read_fur_modeling_options(subject_id);
    case 'suv'
        modeling_options.model = 'suv';
    case 'suvr'
        dyn = aivo_get_info(subject_id,'dynamic');
        if(iscell(dyn))
            dyn = dyn{1};
        end
        modeling_options = aivo_read_suvr_modeling_options(subject_id,dyn);
    otherwise
        error('Unknown model %s',model);
end

roi_set = aivo_get_info(subject_id,'roi_set');
if(iscell(roi_set))
    roi_set = roi_set{1};
    if(strcmp(roi_set,'null'))
        roi_set = 'tracer_default';
        aivo_set_info(subject_id,'roi_set',roi_set);
    end
end

modeling_options.roi_set = roi_set;
modeling_options.cut_time = cut_time;

end