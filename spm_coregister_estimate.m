function spm_coregister_estimate(reference_image,source_image,other_images)

if(ischar(other_images))
    other_images = {other_images};
end

matlabbatch{1}.spm.spatial.coreg.estimate.ref = {reference_image};
matlabbatch{1}.spm.spatial.coreg.estimate.source = {source_image};
matlabbatch{1}.spm.spatial.coreg.estimate.other = other_images;
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

end