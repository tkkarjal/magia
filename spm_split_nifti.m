function static_niftis = spm_split_nifti(filename,outdir)

matlabbatch{1}.spm.util.split.vol = {filename};
matlabbatch{1}.spm.util.split.outdir = {outdir};

f_old = get_filenames(outdir,'*.nii');

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

f_new = get_filenames(outdir,'*.nii');
static_niftis = setdiff(f_new,f_old);

end