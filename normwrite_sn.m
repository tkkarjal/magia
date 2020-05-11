function normalized_images = normwrite_sn(image_files,sn_file,interp)

matlabbatch{1}.spm.tools.oldnorm.write.subj.matname = {sn_file};
matlabbatch{1}.spm.tools.oldnorm.write.subj.resample = image_files;
matlabbatch{1}.spm.tools.oldnorm.write.roptions.preserve = 0;
matlabbatch{1}.spm.tools.oldnorm.write.roptions.bb = [-90 -126 -72;90 90 108];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.vox = [2 2 2];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.interp = interp;
matlabbatch{1}.spm.tools.oldnorm.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.tools.oldnorm.write.roptions.prefix = 'w';

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

normalized_images = add_prefix(image_files,'w');

end
