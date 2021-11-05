function pet_file = magia_get_pet_file(subject)
% Copies the nifti file from the nii directory. If the nifti does not
% exist, converts the dcm or ecat files to infti into the nii directory,
% from which the image is then copied to the main PET directory.

data_path = getenv('DATA_DIR');
d = sprintf('%s/%s',data_path,subject);
if(~exist(d,'dir'))
    error('Could not find the subject folder %s.',d);
end
pet_dir = sprintf('%s/PET',d);
nii_dir = sprintf('%s/nii',pet_dir);
if(~exist(nii_dir,'dir'))
    mkdir(nii_dir);
end
nii_pet_file = sprintf('%s/pet_%s.nii',nii_dir,subject);
if(~exist(nii_pet_file,'file'))
    gz_file = sprintf('%s.gz',nii_pet_file);
    if(exist(gz_file,'file'))
        cmd = sprintf('gunzip -rf %s',gz_file);
        status = system(cmd);
        if(status)
            error('Could not unzip %s.',gz_file);
        end
    else
        dcm_dir = sprintf('%s/dcm',pet_dir);
        ecat_dir = sprintf('%s/ecat',pet_dir);
        if(exist(dcm_dir,'dir'))
            magia_convert_to_nifti(dcm_dir,nii_dir,nii_pet_file);
        elseif(exist(ecat_dir,'dir'))
            magia_convert_to_nifti(ecat_dir,nii_dir,nii_pet_file);
        else
            error('Could not find image files for %s.',subject);
        end
    end
end

pet_file = sprintf('%s/pet_%s.nii',pet_dir,subject);
copyfile(nii_pet_file,pet_file,'f');
cmd = sprintf('gzip -rf %s',nii_pet_file);
system(cmd);

end
