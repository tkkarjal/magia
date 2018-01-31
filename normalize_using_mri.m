function normalized_images = normalize_using_mri(mri_file,images_coregistered_with_mri,deformation_field)

if(~ischar(mri_file))
    error('The input argument mri_file must be a string (full path to the image file).');
end

if(iscell(images_coregistered_with_mri))
    resampled_images = [mri_file;images_coregistered_with_mri];
else
    resampled_images = {mri_file;images_coregistered_with_mri};
end

matlabbatch{1}.spm.spatial.normalise.write.subj.def = {deformation_field};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = resampled_images;
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-78 -112 -70
                                                          78 76 85];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 1;
matlabbatch{1}.spm.spatial.normalise.write.woptions.prefix = 'w';

normalized_images = add_prefix(resampled_images,'w');

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

p = fileparts(mri_file);
matlabbatch_filename = sprintf('%s/matlabbatch_normalize.mat',p);
save(matlabbatch_filename,'matlabbatch');

end

function new_filename = add_prefix(filename,prefix)

if(ischar(filename))
    [p,n,e] = fileparts(filename);
    n = [prefix n];
    new_filename = fullfile(p,[n e]);
elseif(iscell(filename))
    new_filename = cell(size(filename));
    for i = 1:length(filename)
        new_filename{i} = add_prefix(filename{i},prefix);
    end
else
    error('filename must be either a string or a cell array.');
end

end
