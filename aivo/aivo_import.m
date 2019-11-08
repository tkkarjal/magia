function T = aivo_import(spreadsheet)

T = readtable(spreadsheet);

num_studies = size(T,1);
num_columns = size(T,2);

column_names = T.Properties.VariableNames;

%% First modify the table so that it better satisfies the requirements

for i = 1:num_columns
    current_column = column_names{i};
    column_values = T.(current_column);
    if(strcmp(current_column,'injection_time'))
        column_values = cellstr(datestr(column_values,13));
    elseif(ismember(current_column,{'dc' 'weight' 'height' 'dose' 'start_time' 'glucose' 'hct'}))
        if(iscell(column_values))
            column_values = str2double(column_values);
        end
    end
    for j = 1:num_studies
        switch current_column
            case {'patient_id' 'ac_number' 'study_date' 'project' 'group_name' 'description' 'scanner' 'tracer' 'mri_code' 'notes' 'injection_time'}
                val = column_values{j};
                updated_val = aivo_import_check(val,current_column,j);
                column_values{j} = updated_val;
            case {'dc' 'weight' 'height' 'dose' 'start_time' 'glucose' 'hct'}
                val = column_values(j);
                updated_val = aivo_import_check(val,current_column,j);
                column_values(j) = updated_val;
        end
    end
    T.(current_column) = column_values;
end

%% Insert new studies to the study_table table
% Inserting new rows to study_table will automatically trigger insertion of
% rows also to patient, lab, study and magia tables

ac = [T.ac_number;T.mri_code];
image_id = ac;
pet = [ones(num_studies,1);zeros(num_studies,1)];
mri = [zeros(num_studies,1);ones(num_studies,1)];
t = table(image_id,ac,pet,mri);

% insert(conn,'megabase.aivo2.study_table',t.Properties.VariableNames,t);

project_columns = {'image_id','project','group_name','description'};
project_T = T(:,ismember(T.Properties.VariableNames,project_columns));
% insert(conn,'megabase.aivo2.project',project_T.Properties.VariableNames,project_T);

%% Update the contents of the other tables

% for i = 1:num_columns
%     field = column_names{i};
%     aivo_set_info(T.ac_number,field,T.(field));
% end

end