function aivo_set_info(subject_id,field,value)
% It is possible to add the same value for every subject_id. Only one field
% is accepted. Note that if many subject_ids are given, they must be given
% in alphabetical order.

%% Initialize

conn = aivo_connect();

study_cols = columns(conn,'megapet','aivo2','study');
patient_cols = columns(conn,'megapet','aivo2','patient');
project_cols = columns(conn,'megapet','aivo2','project');
magia_cols = columns(conn,'megapet','aivo2','magia');
lab_cols = columns(conn,'megapet','aivo2','lab');
inventory_cols = columns(conn,'megapet','aivo2','inventory');
mri_cols = {'freesurfed'};
study_code_cols = columns(conn,'megapet','aivo2','study_code');

if(ismember(field,study_cols))
    table_name = 'study';
elseif(ismember(field,magia_cols))
    table_name = 'magia';
elseif(ismember(field,patient_cols))
    table_name = 'patient';
elseif(ismember(field,project_cols))
    table_name = 'project';
elseif(ismember(field,inventory_cols))
    table_name = 'inventory';
elseif(ismember(field,lab_cols))
    table_name = 'lab';
elseif(ismember(field,mri_cols))
    table_name = 'mri';
elseif(ismember(field,study_code_cols))
    table_name = 'study_code';
else
    error('Could not find the field ''%s'' from AIVO',field);
end

long_table_name = ['"megabase"."aivo2".' table_name];

if(~iscell(value))
    if(isnumeric(value))
        value = num2cell(value);
    else
        value = {value};
    end
end
if(~iscell(field))
    field = {field};
end
if(~iscell(subject_id))
    subject_id = {subject_id};
end

%% Discard the subjects that are not listed in the requested table

found = aivo_check_found(subject_id,table_name);

if(~all(found))
    missing_subjects = subject_id(~found);
    n_missing = length(missing_subjects);
    for i = 1:n_missing
        if(i == 1)
            msg = sprintf('Could not find the following studies from the table %s:',long_table_name);
        end
        msg = sprintf('%s %s',msg,missing_subjects{i});
        if(i == n_missing)
            msg = sprintf('%s\n',msg);
            warning('%sThe information will not be written for the listed studies. Continuing with the remaining %.0f studies\n',msg,sum(found));
        end
    end
end

n_values = length(value);
if(n_values > 1)
    value = value(found);
end

%% Write the information to the database

subject_id = subject_id(found);
if(~isempty(subject_id))
    n_subs = length(subject_id);

    if(n_values == 1 && n_subs >= 1) % A single value for all subjects
        whereclause = 'WHERE';
        for i = 1:n_subs
            if(i == 1)
                whereclause = sprintf('%s image_id = ''%s''',whereclause,subject_id{i});
            else
                whereclause = sprintf('%s OR image_id = ''%s''',whereclause,subject_id{i});
            end
        end
        update(conn,long_table_name,field,value,whereclause)
    elseif(n_values > 1 && n_subs > 1) % Subjects have a distinct value
        if(n_values == n_subs)
            for i = 1:n_subs
                whereclause = sprintf('WHERE image_id = ''%s''',subject_id{i});
                update(conn,long_table_name,field,value(i),whereclause)
            end
        else
            error('The number of values does not match the number of subjects.');
        end
    else
        error('Inconsistent combination of values and subjects. The function can either use a single value for all subjects, or a distinct value per subject.');
    end
end

close(conn);

end