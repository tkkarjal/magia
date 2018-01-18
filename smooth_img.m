function smoothed_files = smooth_img(imgs,fwhm)

prefix = 's';

if(ischar(imgs))
    imgs = {imgs};
end

[p,name,ext] = cellfun(@fileparts,imgs,'UniformOutput',0);
new_name = strcat(prefix,name);

matlabbatch{1}.spm.spatial.smooth.data = imgs;
matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm.*[1 1 1];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = prefix;

spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

smoothed_files = strcat(cellfun(@fullfile,p,new_name,'UniformOutput',0),ext);
end