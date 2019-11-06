function aivo_store_magia_info(subject,specs)

aivo_set_info(subject,'magia_time',char(datetime('now','format','yyyy-MM-dd hh:mm:ss')));
aivo_set_info(subject,'found',1);
aivo_set_info(subject,'analyzed',1);
aivo_set_info(subject,'error','');
aivo_set_info(subject,'magia_githash',magia_get_githash);

if(strcmp(specs.magia.roi_type,'freesurfer'))
    mri_code = specs.study.mri_code;
    aivo_set_info(mri_code,'freesurfed',1);
    aivo_set_info(mri_code,'found',1);
elseif(strcmp(specs.magia.norm_method,'mri'))
    mri_code = specs.study.mri_code;
    aivo_set_info(mri_code,'found',1);
end

end