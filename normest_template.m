function source2template = normest_template(source_file,template_file,smosrc,smoref,regtype)

matlabbatch{1}.spm.tools.oldnorm.est.subj.source = {source_file};
matlabbatch{1}.spm.tools.oldnorm.est.subj.wtsrc = '';
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.template = {template_file};
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.weight = '';
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smosrc = smosrc;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.smoref = smoref;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.regtype = regtype;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.cutoff = 25;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.nits = 10;
matlabbatch{1}.spm.tools.oldnorm.est.eoptions.reg = 1;

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

[p,n] = fileparts(source_file);
source2template = sprintf('%s/%s_sn.mat',p,n);

end