function magia_check_specs(specs)

%% specs.study: Mandatory fields
mandatory_study_fields = {'tracer' 'frames'};
empty_study_fields = cell(length(mandatory_study_fields),1);
missing_study_fields = empty_study_fields;

for i = 1:length(mandatory_study_fields)
    field = mandatory_study_fields{i};
    if(isfield(specs.study,field))
        if(isempty(specs.study.(field)))
            empty_study_fields{i} = field;
        end
    else
        missing_study_fields{i} = field;
    end
end

empty_study_fields(cellfun(@isempty,empty_study_fields)) = [];
if(~isempty(empty_study_fields))
    msg1 = 'The following mandatory study fields were empty: ';
    for i = 1:length(empty_study_fields)
        field = empty_study_fields{i};
        msg1 = sprintf('%s ''%s''',msg1,field);
    end
else
    msg1 = '';
end

missing_study_fields(cellfun(@isempty,missing_study_fields)) = [];
if(~isempty(missing_study_fields))
    msg2 = 'The following mandatory study fields were missing: ';
    for i = 1:length(missing_study_fields)
        field = missing_study_fields{i};
        msg2 = sprintf('%s ''%s''',msg2,field);
    end
else
    msg2 = '';
end

%% specs.magia: Mandatory fields

mandatory_magia_fields = {'model' 'input_type' 'roi_type' 'dc' 'rc' 'fwhm_pre' 'fwhm_post' 'fwhm_roi' 'cpi' 'cut_time' 'gu'};
empty_magia_fields = cell(length(mandatory_magia_fields),1);
missing_magia_fields = empty_study_fields;

for i = 1:length(mandatory_magia_fields)
    field = mandatory_magia_fields{i};
    if(isfield(specs.magia,field))
        if(isempty(specs.magia.(field)))
            empty_magia_fields{i} = field;
        end
    else
        missing_magia_fields{i} = field;
    end
end

empty_magia_fields(cellfun(@isempty,empty_magia_fields)) = [];
if(~isempty(empty_magia_fields))
    msg3 = 'The following mandatory magia fields were empty: ';
    for i = 1:length(empty_magia_fields)
        field = empty_magia_fields{i};
        msg3 = sprintf('%s ''%s''',msg3,field);
    end
else
    msg3 = '';
end

missing_magia_fields(cellfun(@isempty,missing_magia_fields)) = [];
if(~isempty(missing_magia_fields))
    msg4 = 'The following mandatory magia fields were missing: ';
    for i = 1:length(missing_magia_fields)
        field = missing_magia_fields{i};
        msg4 = sprintf('%s ''%s''',msg4,field);
    end
else
    msg4 = '';
end

%% ROI type

if(isfield(specs.magia,'roi_type'))
    switch specs.magia.roi_type
        case 'atlas'
            if(isfield(specs.magia,'mni_roi_mask_dir'))
                if(isempty(specs.magia.mni_roi_mask_dir))
                    msg5 = 'No ''mni_roi_mask_dir'' was specified even if ''roi_type'' is ''atlas''.';
                else
                    msg5 = '';
                end
            else
                msg5 = 'No ''mni_mni_roi_mask_dir'' was specified even if ''roi_type'' is ''atlas''.';
            end
            
        case 'freesurfer'
            if(isfield(specs.magia,'roi_set'))
                if(isempty(specs.magia.roi_set))
                    msg5 = 'No ''roi_set'' was specified even if ''roi_type'' is ''freesurfer''.';
                else
                    if(isfield(specs.study,'mri_code'))
                        if(isempty(specs.study.mri_code))
                            msg5 = '''mri_code'' was not specified even if the ROIs are supposed to be defined using FreeSurfer.';
                        else
                            msg5 = '';
                        end
                    else
                        msg5 = '''mri_code'' was not specified even if the ROIs are supposed to be defined using FreeSurfer.';
                    end
                end
            else
                msg5 = 'No ''roi_set'' was specified even if ''roi_type'' is ''freesurfer''.';
            end
        otherwise
            msg5 = '''roi_type'' should be either ''atlas'' or ''freesurfer''.';
    end
else
    msg5 = '';
end

%% Model

if(isfield(specs.magia,'model'))
    if(isempty(specs.magia.model))
        msg6 = '''model'' was not specified.';
    else
        specified_model = specs.magia.model;
        available_models = {'suv' 'suvr' 'srtm' 'two_tcm' 'logan' 'logan_ref' 'patlak' 'patlak_ref' 'ma1' 'fur'};
        if(ismember(specified_model,available_models))
            msg6 = '';
        else
            msg6 = sprintf('The model ''%s'' is not supported by magia.',specified_model);
        end
    end
else
    msg6 = '''model'' was not specified.';
end

%% Input type

if(isfield(specs.magia,'input_type'))
    if(isempty(specs.magia.input_type))
        msg7 = '''input_type'' was not specified.';
    else
        specified_input_type = specs.magia.input_type;
        supported_input_types = {'plasma' 'blood' 'plasma&blood' 'ref' 'sca_ref'};
        if(ismember(specified_input_type,supported_input_types))
            if(strcmp(specified_input_type,'sca_ref'))
                if(isfield(specs.magia,'classfile'))
                    if(isempty(specs.magia.classfile))
                        msg7 = '''classfile'' was not specified even if ''input_type'' was specified as ''sca_ref''';
                    else
                        msg7 = '';
                    end
                else
                    msg7 = '''classfile'' was not specified even if ''input_type'' was specified as ''sca_ref''';
                end
            else
                msg7 = '';
            end
        else
            msg7 = sprintf('The input_type ''%s'' is not supported by magia.',specified_input_type);
        end
    end
else
    msg7 = '';
end

%% Normalization method

if(isfield(specs.magia,'norm_method'))
    if(isempty(specs.magia.norm_method))
        msg8 = '''norm_method'' was not specified.';
    else
        specified_norm_method = specs.magia.norm_method;
        supported_norm_methods = {'pet' 'mri'};
        if(ismember(specified_norm_method,supported_norm_methods))
            if(strcmp(specified_norm_method,'mri'))
                if(isfield(specs.study,'mri_code'))
                    if(isempty(specs.study.mri_code))
                        msg8 = '''mri_code'' was not specified even if normalization is supposed to be done via MRI.';
                    else
                        msg8 = '';
                    end
                else
                    msg8 = '''mri_code'' was not specified even if normalization is supposed to be done via MRI.';
                end
            else
                if(isfield(specs.magia,'template'))
                    if(isempty(specs.magia.template))
                        msg8 = '''template'' was not specified even if normalization is supposed to be done via PET.';
                    else
                        msg8 = '';
                    end
                else
                    msg8 = '''template'' was not specified even if normalization is supposed to be done via PET.';
                end
            end
        else
            msg8 = sprintf('The ''norm_method'' ''%s'' is not supported by magia. It should be either ''mri'' or ''pet''.',specified_norm_method);
        end
    end
else
    msg8 = '';
end

%% NaN check

msg9 = '';
specs_fields = fieldnames(specs);
for i = 1:length(specs_fields)
    field = specs_fields{i};
    s = specs.(field);
    sub_spec_fields = fieldnames(s);
    for  j = 1:length(sub_spec_fields)
        f = sub_spec_fields{j};
        switch f
            case {'cut_time' 'weight' 'scanner' 'dose'}
                
            otherwise
                v = s.(f);
                if(isnan(v))
                    if(isempty(msg9))
                        msg9 = sprintf('The following fields were NaN: specs.%s.%s',field,f);
                    else
                        msg9 = sprintf('%s specs.%s.%s',msg9,field,f);
                    end
                end
        end
    end
end

%% Glucose

if(isfield(specs.magia,'gu'))
    if(isempty(specs.magia.gu) || isnan(specs.magia.gu))
        msg10 = '''gu'' was not specified.';
    else
        specified_gu = specs.magia.gu;
        if(specified_gu)
            if(isfield(specs.study,'glucose'))
                specified_glucose = specs.study.glucose;
                if(strcmp(specified_glucose,'No Data'))
                    msg10 = 'Plasma glucose concentration (the field glucose) was not specified even if gu = 1.';
                end
            else
                msg10 = 'Plasma glucose concentration (the field glucose) was not specified even if gu = 1.';
            end
        else
            msg10 = '';
        end
        msg10 = '';
    end
else
    msg10 = '''gu'' was not specified.';
end

%% Print observations

if(isempty(msg1) && isempty(msg2) && isempty(msg3) && isempty(msg4) && isempty(msg5) && isempty(msg6) && isempty(msg7) && isempty(msg8) && isempty(msg9) && isempty(msg10))
    fprintf('No problems found from the specs.\n');
else
    msg = 'The following problems were observed:';
    if(~isempty(msg1))
        msg = sprintf('%s\n\n%s',msg,msg1);
    end
    if(~isempty(msg2))
        msg = sprintf('%s\n\n%s',msg,msg2);
    end
    if(~isempty(msg3))
        msg = sprintf('%s\n\n%s',msg,msg3);
    end
    if(~isempty(msg4))
        msg = sprintf('%s\n\n%s',msg,msg4);
    end
    if(~isempty(msg5))
        msg = sprintf('%s\n\n%s',msg,msg5);
    end
    if(~isempty(msg6))
        msg = sprintf('%s\n\n%s',msg,msg6);
    end
    if(~isempty(msg7))
        msg = sprintf('%s\n\n%s',msg,msg7);
    end
    if(~isempty(msg8))
        msg = sprintf('%s\n\n%s',msg,msg8);
    end
    if(~isempty(msg9))
        msg = sprintf('%s\n\n%s',msg,msg9);
    end
    if(~isempty(msg10))
        msg = sprintf('%s\n\n%s',msg,msg10);
    end
    error('%s\n\nPlease correct the mistakes and try again.\n',msg);
end
            
end
