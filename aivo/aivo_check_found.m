function found = aivo_check_found(image_id)

aivo_subjects = aivo_get_subjects();
found = ismember(image_id,aivo_subjects);

end