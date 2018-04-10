function aivo_import(spreadsheet)

T = readtable(spreadsheet);
fields = T.Properties.VariableNames;

pet_fields = {'image_id' 'ac' 'study_code' 'study_date' 'project' 'group_name' 'description' 'scanner' 'tracer' 'frames' 'start_time' 'mri' 'plasma' 'dynamic' 'dc' 'weight' 'height' 'dose' 'notes' 'type' 'source' 'injection_time'};
patient_fields = {'patient_id' 'study_date'};
pet_idx = ismember(fields,pet_fields);
patient_idx = ismember(fields,patient_fields);

T_pet = T(:,pet_idx);
T_patient = T(:,patient_idx);

conn = aivo_connect();

insert(conn,'megabase.aivo.pet',pet_fields,T_pet);
insert(conn,'megabase.aivo.patient',patient_fields,T_patient);

close(conn);

end