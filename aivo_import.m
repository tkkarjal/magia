function aivo_import(spreadsheet)

T = readtable(spreadsheet);
N = size(T,1);

%% Extract birthdate and gender from the patient_id

birthday = cell(N,1);
gender = cell(N,1);

for i = 1:N
    pid = T.patient_id{i};
    birthday{i} = aivo_extract_birthday(pid);
    gender{i} = aivo_extract_gender(pid);
end

T.gender = gender;
T.birthday = birthday;
T.age = (datenum(T.study_date) - datenum(datetime(T.birthday,'format','yyyy-MM-dd')))/365;
T.study_date = char(T.study_date);
T.pet = ones(N,1);

%%

fields = T.Properties.VariableNames;
pet_fields = {'image_id' 'ac' 'study_code' 'study_date' 'project' 'group_name' 'description' 'scanner' 'tracer' 'frames' 'start_time' 'mri' 'plasma' 'dynamic' 'dc' 'weight' 'height' 'dose' 'notes' 'type' 'source' 'injection_time' 'gender' 'age'};
patient_fields = {'patient_id' 'study_date' 'gender' 'birthday' 'age' 'pet'};
pet_idx = ismember(fields,pet_fields);
patient_idx = ismember(fields,patient_fields);

T_pet = T(:,pet_idx);
T_patient = T(:,patient_idx);

conn = aivo_connect();

insert(conn,'megabase.aivo.pet',pet_fields,T_pet);
N = size(T,1);

image_id_idx = strcmp(fields,'image_id');

for i = 1:N
    id = table2array(T(i,image_id_idx));
    whereclause = sprintf('WHERE patient.image_id = ''%s''',id{1});
    update(conn,'megabase.aivo.patient',patient_fields,T_patient,whereclause);
end

close(conn);

end