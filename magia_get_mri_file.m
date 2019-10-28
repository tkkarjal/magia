function mri_file = magia_get_mri_file(pet_code,mri_code)

data_dir = getenv('DATA_DIR');
mri_dir = getenv('MRI_DIR');

t1_folder = sprintf('%s/%s/T1',mri_dir,mri_code);
cmd = sprintf('gunzip -rf %s',t1_folder);
system(cmd);

mri_filename = sprintf('mri_%s.nii',pet_code);
convert_to_nifti(t1_folder,t1_folder,mri_filename);
mri_file = sprintf('%s/%s',t1_folder,mri_filename);

target_dir = sprintf('%s/%s/MRI',data_dir,pet_code);
if(~exist(target_dir,'dir'))
    mkdir(target_dir);
end

movefile(mri_file,target_dir);
mri_file = sprintf('%s/mri_%s.nii',target_dir,pet_code);

center_image(mri_file);

cmd = sprintf('gzip -r %s',t1_folder);
system(cmd);

end