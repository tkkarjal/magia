function birthday = aivo_extract_birthday(patient_id)

if(iscell(patient_id))
    patient_id = patient_id{1};
end

dd = patient_id(1:2);
mm = patient_id(3:4);
yy = patient_id(5:6);
s = patient_id(7);

if(strcmp(s,'-'))
    yyyy = ['19' yy];
else
    yyyy = ['20' yy];
end

birthday = [yyyy '-' mm '-' dd];

end