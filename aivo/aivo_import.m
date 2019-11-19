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
                    val = column_values{j}
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
return
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
description = T.description;
group_name = T.group_name;

project_T = table(image_id,project,description,group_name);

conn = aivo_connect;
insert(conn,'megabase.aivo2.study_code',t.Properties.VariableNames,t);
insert(conn,'megabase.aivo2.project',{'image_id' 'project' 'description' 'group_name'},project_T);
close(conn);

%% Update the contents of the other tables

remaining_columns = {'patient_id' 'study_date' 'scanner' 'tracer' 'mri_code' 'notes' 'injection_time' 'dc' 'weight' 'height' 'dose' 'start_time' 'glucose' 'hct'};

for i = 1:length(remaining_columns)
    field = remaining_columns{i};
    aivo_set_info(T.ac_number,field,T.(field));
end

end