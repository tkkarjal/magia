function archive_results_new(subject)

fprintf('Archiving results of %s...',subject);

data_dir = getenv('DATA_DIR');
archive_dir = getenv('MAGIA_ARCHIVE');
source_dir = sprintf('%s/%s',data_dir,subject);
target_dir = sprintf('%s/%s',archive_dir,subject);
if(~exist(target_dir,'dir'))
    mkdir(target_dir);
end

mri_dir = sprintf('%s/MRI',source_dir);
if(exist(mri_dir,'dir'))
    target_mri_dir = sprintf('%s/MRI',target_dir);
    if(~exist(target_mri_dir,'dir'))
        mkdir(target_mri_dir);
    end
    copyfile(mri_dir,target_mri_dir,'f');
end

mask_dir = sprintf('%s/masks',source_dir);
if(exist(mask_dir,'dir'))
    target_mask_dir = sprintf('%s/masks',target_dir);
    if(~exist(target_mask_dir,'dir'))
        mkdir(target_mask_dir);
    end
    copyfile(mask_dir,target_mask_dir,'f');
end

results_dir = sprintf('%s/results',source_dir);
if(exist(results_dir,'dir'))
    target_results_dir = sprintf('%s/results',target_dir);
    if(~exist(target_results_dir,'dir'))
        mkdir(target_results_dir);
    end
    copyfile(results_dir,target_results_dir,'f');
end

plasma_dir = sprintf('%s/plasma',source_dir);
if(exist(plasma_dir,'dir'))
    target_plasma_dir = sprintf('%s/plasma',target_dir);
    if(~exist(target_plasma_dir,'dir'))
        mkdir(target_plasma_dir);
    end
    copyfile(plasma_dir,target_plasma_dir,'f');
end

blood_dir = sprintf('%s/blood',source_dir);
if(exist(blood_dir,'dir'))
    target_blood_dir = sprintf('%s/blood',target_dir);
    if(~exist(target_blood_dir,'dir'))
        mkdir(target_blood_dir);
    end
    copyfile(blood_dir,target_blood_dir,'f');
end

f = {
    sprintf('%s/info_%s.txt',source_dir,subject)
    sprintf('%s/modeling_options_%s.txt',source_dir,subject)
    sprintf('%s/qc_%s.ps',source_dir,subject)
    sprintf('%s/githash_%s.txt',source_dir,subject)
    sprintf('%s/specs_%s.txt',source_dir,subject)
   };

for i = 1:length(f)
    if(exist(f{i},'file'))
        copyfile(f{i},target_dir,'f');
    end
end

pet_dir = sprintf('%s/PET',source_dir);
target_pet_dir = sprintf('%s/PET',target_dir);
if(~exist(target_pet_dir,'dir'))
    mkdir(target_pet_dir);
end

f = get_filenames(pet_dir,'*.');
for i = 1:length(f)
    copyfile(f{i},target_pet_dir,'f');
end

cmd = sprintf('chmod -R 777 %s',target_dir);
system(cmd);

end
