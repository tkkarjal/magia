function resliced_source_images = spm_coregister_reslice(reference_image,source_images,interp)

prefix = 'c';

matlabbatch{1}.spm.spatial.coreg.write.ref = {reference_image};
if(ischar(source_images))
    matlabbatch{1}.spm.spatial.coreg.write.source = {source_images};
else
    matlabbatch{1}.spm.spatial.coreg.write.source = source_images;
end

matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = interp;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = prefix;

resliced_source_images = add_prefix(source_images,prefix);

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

p = fileparts(reference_image);
matlabbatch_filename = sprintf('%s/matlabbatch_coreg_reslice.mat',p);
save(matlabbatch_filename,'matlabbatch');

end