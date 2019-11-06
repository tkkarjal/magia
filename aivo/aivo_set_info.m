function aivo_set_info(subject_id,field,value)
% It is possible to add the same value for every subject_id. Name the fields as in the columns in aivo.pet.
% Do not enter many fields.

conn = aivo_connect();

switch field
    case {'study_date' 'tracer' 'scanner' 'mri_code' 'frames' 'dose' 'plasma' 'num_frames' 'scan_start_time' 'injection_time' 'type' 'source' 'dynamic'}
        table_name = '"megabase"."aivo2".study';
        cols = columns(conn,'megapet','aivo2','study');
        field_edits_allowed = 1;
    case {'model' 'dc' 'rc' 'cpi' 'cut_time' 'roi_type' 'roi_set' 'mni_roi_atlas_dir' 'input_type' 'fwhm_pre' 'fwhm_post' 'norm_method' 'fwhm_roi' 'mc_excluded_frames' 'mc_fwhm' 'mc_rtm' 'mc_ref_frame' 'template'}
        table_name = '"megabase"."aivo2".magia';
        cols = columns(conn,'megapet','aivo2','magia');
        field_edits_allowed = 1;
    case {'patient_id' 'weight' 'height' 'age' 'sex' 'birthday' 'handedness' 'smoker'}
        table_name = '"megabase"."aivo2".patient';
        cols = columns(conn,'megapet','aivo2','patient');
        field_edits_allowed = 1;
    case {'found' 'freesurfed' 'analyzed' 'magia_time' 'magia_githash' 'error'}
        table_name = '"megabase"."aivo2".inventory';
        cols = columns(conn,'megapet','aivo2','inventory');
        field_edits_allowed = 1;
    otherwise
        error('Unknown field %s.',field);
end

if(~ismember(field,cols))
    error('You have entered an invalid field!');
end;

if(~iscell(value))
    value = {value};
end
if(~iscell(field))
    field = {field};
end

if(~ischar(subject_id)) %many subjects 
    if(length(subject_id) == length(value)) %different value for every subject
        for i=1:length(subject_id)
            validated = aivo_get_info(subject_id{i},'validated');
            if(validated ~= 1 || field_edits_allowed)
                whereclause = sprintf('WHERE image_id = %s%s%s',char(39),subject_id{i},char(39));
                update(conn,table_name,field,value(i),whereclause)
            else
                warning('Subject_id %s is validated and cannot be updated!',subject_id{i});
            end
        end
        return
    else
        if(length(value)>1)
            error('You have entered a different number of subject_id:s and values. If you want to add different values for different subject_id:s you must specify one value for every subject_id.');
        end
    end
end

current_subjects = aivo_get_subjects;
invalid_id = setdiff(subject_id,current_subjects); 
subject_id = intersect(subject_id,current_subjects); %exclude invalid subjects
for i=1:length(invalid_id)
    warning('Image_id %s does not exist! Use aivo_create_subject.m to create new subjects.',invalid_id{i})
end

if ~field_edits_allowed
    current_validated = aivo_get_subjects('validated',1);
    current_unvalidated = setdiff(current_subjects,current_validated);
    if(~isempty(current_unvalidated)) %exclude validated subjects
        validated = intersect(subject_id,current_validated);
        subject_id = intersect(subject_id,current_unvalidated);
        for i=1:length(validated)
            warning('Subject_id %s is validated and cannot be updated!',validated{i});
        end
    end
    if(isempty(subject_id)) %end if no subjects
        return
    end
end
    
if(length(subject_id)>1) %many subjects
    if(length(subject_id) == length(value)) %different value for every subject (not working at the moment!)
        %for i=1:length(subject_id)
            %whereclause = sprintf('WHERE image_id = %s%s%s',char(39),subject_id{i},char(39));
            %update(conn,'"megabase"."aivo2".pet',field,value(i),whereclause)
        %end
    else
        if(length(value)) %same value for all subjects
            whereclause = 'WHERE';
            for i=1:length(subject_id)
                if(i==1)
                    whereclause = sprintf('%s image_id = %s%s%s',whereclause,char(39),subject_id{i},char(39));
                else
                    whereclause = sprintf('%s OR image_id = %s%s%s',whereclause,char(39),subject_id{i},char(39));
                end
            end
            update(conn,table_name,field,value,whereclause)
        else
            error('You have entered a different number of subject_id:s and values. If you want to add different values for different subject_id:s you must specify one value for every subject_id.');
        end
    end
else %one subject
    if(length(value)==1) %one value
        table_name_only=strsplit(table_name,'.');
        whereclause = sprintf('WHERE %s.image_id = %s%s%s',table_name_only{3},char(39),subject_id{1},char(39));
        update(conn,table_name,field,value,whereclause)
    else
        error('You have entered a different number of subject_id:s and values. If you want to add different values for different subject_id:s you must specify one value for every subject_id.');
    end
end

close(conn);

end
