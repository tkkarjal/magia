function [full_file,seg_file,bet_file] = process_mri(subject,mri_code)

data_path = getenv('DATA_DIR');
mri_dir = sprintf('%s/%s/MRI',data_path,subject);
if(~exist(mri_dir,'dir'))
    mkdir(mri_dir);
end

%% FreeSurfer

[seg_file,full_file,bet_file] = magia_recon_all(subject,mri_code);

%% Rigid transformation to MNI space

spm_path = getenv('SPM_DIR');
mni_template = sprintf('%s/canonical/avg305T1.nii', spm_path);

other_images = {
    seg_file
    bet_file
    };

if(exist(mni_template,'file'))
    spm_coregister_estimate(mni_template,full_file,other_images)
else
    warning('%s: Could not find the MNI template file %s. Skipping coregistration of the MRI data to the template.\n',subject,mni_template);
end

end
