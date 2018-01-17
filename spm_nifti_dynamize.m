function spm_nifti_dynamize(static_niftis,filename)

if(ischar(static_niftis))
    static_niftis = {static_niftis};
end

matlabbatch{1}.spm.util.cat.vols = static_niftis;
matlabbatch{1}.spm.util.cat.name = filename;
matlabbatch{1}.spm.util.cat.dtype = 0;

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

if(length(static_niftis)>1)
    cellfun(@delete,static_niftis);
end

end