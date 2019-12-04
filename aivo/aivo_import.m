function T = aivo_import(spreadsheet)

T = readtable(spreadsheet,'DateTimeType','text');

%% Exclude columns that consists of NaNs

column_names = T.Properties.VariableNames;

for i = 1:size(T,2)
    field = column_names{i};
    val = T.(field);
    if(~iscell(val) && ~isdatetime(val) && all(isnan(val)))
        T.(field) = [];
    end
end

column_names = T.Properties.VariableNames;

num_studies = size(T,1);
num_columns = size(T,2);

%% First modify the table so that it better satisfies the requirements

for i = 1:num_columns
    current_column = column_names{i};
    column_values = T.(current_column);
    if(ismember(current_column,{'dc' 'weight' 'height' 'dose' 'start_time' 'glucose' 'hct'}))
        if(iscell(column_values))
            column_values = str2double(column_values);
        end
    end
    for j = 1:num_studies
        switch current_column
            case {'patient_id' 'ac_number' 'study_date' 'project' 'group_name' 'description' 'scanner' 'tracer' 'mri_code' 'notes' 'injection_time'}
                    val = column_values{j};
                    if(~isempty(val))
                        updated_val = aivo_import_check(val,current_column,j);
                        column_values{j} = updated_val;
                    end
            case {'dc' 'weight' 'height' 'dose' 'start_time' 'glucose' 'hct'}
                val = column_values(j);
                if(~isempty(val))
                    updated_val = aivo_import_check(val,current_column,j);
                    column_values(j) = updated_val;
                end
        end
    end
    T.(current_column) = column_values;
end

%% Insert new studies to the study_table table
% Inserting new rows to study_table will automatically trigger insertion of
% rows also to patient, lab, study and magia tables

if(ismember('mri_code',column_names))
    ac = [T.ac_number;T.mri_code];
    image_id = ac;
    pet = [ones(num_studies,1);zeros(num_studies,1)];
    mri = [zeros(num_studies,1);ones(num_studies,1)];
else
    ac = T.ac_number;
    image_id = ac;
    pet = ones(num_studies,1);
    mri = zeros(num_studies,1);
end
t = table(image_id,ac,pet,mri);

image_id = T.ac_number;
empty_idx = cellfun(@isempty,image_id);
project = T.project;
group_name = T.group_name;
description = T.description;


project_T = table(image_id,project,group_name,description);

image_id = T.ac_number;

N = size(T,1);

for i = 1:N

    disp(['Processing subject ' num2str(i) ' of ' num2str(N)])
    
    conn = aivo_connect;
    refresh(conn);
    id = T.ac_number(i);
    found = aivo_check_id(conn,'study_code',id);
    if found
        whereclause = sprintf('WHERE image_id = ''%s''',id{1});
        update(conn,'megabase.aivo2.study_code',t.Properties.VariableNames,t(i,:),whereclause);
    else
        insert(conn,'megabase.aivo2.study_code',t.Properties.VariableNames,t(i,:));
    end
    found = aivo_check_id(conn,'project',id);
    if found
        whereclause = sprintf('WHERE image_id = ''%s''',id{1});
        update(conn,'megabase.aivo2.project',{'image_id' 'project' 'group_name' 'description'},project_T(i,:),whereclause);
    else
        insert(conn,'megabase.aivo2.project',{'image_id' 'project' 'group_name' 'description'},project_T(i,:));
    end

close(conn); 
end


%% Update the contents of the other tables

remaining_columns = {'patient_id' 'study_date' 'scanner' 'tracer' 'mri_code' 'injection_time' 'dc' 'weight' 'height' 'dose' 'scan_start_time'};% 'glucose' 'hct'};

for i = 1:length(remaining_columns) 
    
    field = remaining_columns{i};
    
    disp(['Writing: ' field ', ' num2str(i) ' of ' num2str(length(remaining_columns)) ' columns'])
    
    aivo_set_info(T.ac_number,field,T.(field));
end

end

function refresh(conn)

refresh_cmd = 'REFRESH MATERIALIZED VIEW aivo2.materia';
curs = exec(conn,refresh_cmd);
close(curs);

end

function found = aivo_check_id(conn,table,id)

check_cmd = ['do $$ BEGIN IF (SELECT image_id FROM aivo2.' table ' WHERE image_id = ''' id{1} ''') IS NULL THEN RAISE Exception ''ERROR''; END IF; END $$'];
curs = exec(conn,check_cmd);
if ~strcmp(curs.Message(1:5),'ERROR')
    found = 1;
else
    found = 0;
end

end
