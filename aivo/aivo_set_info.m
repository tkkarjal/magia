function aivo_set_info(subject_id,field,value)
% It is possible to add the same value for every subject_id. Only one field
% is accepted. If many values are passed the value array should be the same
% length of the subject list

conn = aivo_connect();

study_cols = columns(conn,'megapet','aivo2','study');
patient_cols = columns(conn,'megapet','aivo2','patient');
magia_cols = columns(conn,'megapet','aivo2','magia');
lab_cols = columns(conn,'megapet','aivo2','lab');
inventory_cols = columns(conn,'megapet','aivo2','inventory');
mri_cols = {'freesurfed'};

if(ismember(field,study_cols))
    table_name = '"megabase"."aivo2".study';
elseif(ismember(field,magia_cols))
    table_name = '"megabase"."aivo2".magia';
elseif(ismember(field,patient_cols))
    table_name = '"megabase"."aivo2".patient';
elseif(ismember(field,inventory_cols))
    table_name = '"megabase"."aivo2".inventory';
elseif(ismember(field,lab_cols))
    table_name = '"megabase"."aivo2".lab';
elseif(ismember(field,mri_cols))
    table_name = '"megabase"."aivo2".mri';
else
    error('Could not find the field ''%s'' from AIVO',field);
end

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

sorted_subject_id = sort(subject_id);
if(~isequal(sorted_subject_id,subject_id))
    error('The subject IDs were not given in alphabetical order. Please make sure the subjects are given in alphabetical order, make sure that the inserted values then follow the same order, and try again.');
end

n_subs = length(subject_id);
n_values = length(value);

% If we keep rows only for who has glucose concentration in lab.glucose, we
% need to insert instead of update and if there is error in inserting
% (there is already a row) then update

if(n_values == 1 && n_subs >= 1) % A single value for all subjects 
    whereclause = 'WHERE';
    for i = 1:n_subs
        if(i == 1)
            whereclause = sprintf('%s image_id = ''%s''',whereclause,subject_id{i});
            if ~strcmp(field,'glucose')
                update(conn,table_name,field,value,whereclause)
            else
                fieldr={'image_id','glucose','hct'};
                hct=aivo_get_info(subject_id{i},'hct'); %Grabs old hct value to update, if not present like for insert set to 0
                if isnumeric(hct)
                    valuer={subject_id{i},value{1},hct};
                else
                    valuer={subject_id{i},value{1},'0'};
                end
                try
                    datainsert(conn,table_name,fieldr,valuer);
                catch
                    update(conn,table_name,field,value,whereclause)   
                end
            end
        else
            whereclause = sprintf('%s OR image_id = ''%s''',whereclause,subject_id{i});
            if ~strcmp(field,'glucose')
                update(conn,table_name,field,value,whereclause)
            else
                error('Trying to assign same glucose value to a list of subjects!') %It should not be allowed
            end
        end
    end

    
elseif(n_values > 1 && n_subs > 1) % Subjects have a distinct value
    if(n_values == n_subs)
        for i = 1:n_subs
            whereclause = sprintf('WHERE image_id = ''%s''',subject_id{i});
            if ~strcmp(field,'glucose')
                update(conn,table_name,field,value(i),whereclause)
            else
                fieldr={'image_id','glucose','hct'};
                hct=aivo_get_info(subject_id{i},'hct'); %Grabs old hct value to update, if not present like for insert set to 0
                if isnumeric(hct)
                    valuer={subject_id{i},value{i},hct};
                else
                    valuer={subject_id{i},value{i},'0'};
                end
                try
                    datainsert(conn,table_name,fieldr,valuer);
                catch
                    update(conn,table_name,field,value,whereclause)   
                end
            end
        end
    else
        error('The number of values does not match the number of subjects.');
    end
else
    error('Inconsistent combination of values and subjects. The function can either use a single value for all subjects, or a distinct value per subject.');
end

close(conn);

end