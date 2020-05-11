function normalized_images = normwrite_df(image_files,deformation_field,interp_order)

if(ischar(image_files))
    image_files = {image_files};
end

matlabbatch{1}.spm.spatial.normalise.write.subj.def = {deformation_field};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = image_files;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-90 -126 -72;90 90 108];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [2 2 2];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = interp_order;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

normalized_images = add_prefix(image_files,'w');

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

end
