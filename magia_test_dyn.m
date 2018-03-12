function test_dyn = magia_test_dyn(subject)

data_path = getenv('DATA_DIR');
nii_file = sprintf('%s/%s/PET/pet_%s.nii',data_path,subject,subject);
if(exist(nii_file,'file'))
    V = spm_vol(nii_file);
    img = spm_read_vols(V);
    no_frames = size(img,4);
    if(no_frames > 1)
        test_dyn = 1;
    else
        test_dyn = 0;
    end
else
    error('Cannot check if %s is a dynamic study because the file %s was not found.',subject,nii_file);
end

end