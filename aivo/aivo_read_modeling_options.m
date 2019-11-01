function modeling_options = aivo_read_modeling_options(subject_id)

model = aivo_get_info(subject_id,'model');
if(iscell(model))
    model = model{1};
end

if(strcmp(model,'null'))
    tracer = aivo_get_info(subject_id,'tracer');
    if(iscell(tracer))
        tracer = tracer{1};
    end
    model = magia_get_default_model(tracer);
    aivo_set_info(subject_id,'model',model);
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
        modeling_options = aivo_read_suvr_modeling_options(subject_id,dyn);
    case 'logan'
        modeling_options = aivo_read_logan_modeling_options(subject_id);
    case 'logan_ref'
        modeling_options = aivo_read_logan_ref_modeling_options(subject_id);
    otherwise
        error('Could not read modeling options from AIVO because the model %s is not recognized. ',model);
end

end