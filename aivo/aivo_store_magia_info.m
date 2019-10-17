function aivo_store_magia_info(subject)

aivo_set_info(subject,'magia_time',char(datetime('now','format','yyyy-MM-dd hh:mm:ss')));
aivo_set_info(subject,'found',1);
aivo_set_info(subject,'nii',1);
aivo_set_info(subject,'analyzed',1);
aivo_set_info(subject,'error','');
aivo_set_info(subject,'githash',magia_get_githash);

mri_code = aivo_get_info(subject,'mri');
if(iscell(mri_code))
    mri_code = mri_code{1};
end
freesurfed = magia_check_freesurfed(mri_code);
aivo_set_info(subject,'freesurfed',freesurfed);

end