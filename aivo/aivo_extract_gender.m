function gender = aivo_extract_gender(patient_id)

if(iscell(patient_id))
    patient_id = patient_id{1};
end

h = str2double(patient_id(8:10));

if(mod(h,2))
    gender = 'm';
else
    gender = 'f';
end

end