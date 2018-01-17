function [normalized_meanpet,varargout] = normalize_using_template(meanpet_file,template_dir,tracer,varargin)

template_file = sprintf('%s/%s.nii',template_dir,tracer);

matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.source = {meanpet_file};
matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.wtsrc = '';
if(nargin==3)
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = {meanpet_file};
else
    dynamic_pet = varargin{1};
    [p,n] = fileparts(dynamic_pet);
    dynamic_pet = cellstr(spm_select('ExtFpList',p,n));
    matlabbatch{1}.spm.tools.oldnorm.estwrite.subj.resample = [meanpet_file;dynamic_pet];
end
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.template = {template_file};
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.weight = '';
switch tracer
    case '[11c]raclopride'
        matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 6;
        matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 2;
    otherwise
        matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smosrc = 8;
        matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.smoref = 0;
end
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.regtype = 'mni';
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.nits = 16;
matlabbatch{1}.spm.tools.oldnorm.estwrite.eoptions.reg = 1;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.preserve = 0;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.bb = [-78 -112 -70
                                                         78 76 85];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.vox = [1 1 1];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.tools.oldnorm.estwrite.roptions.prefix = 'w';

spm_jobman('initcfg');
spm_jobman('run', matlabbatch);

normalized_meanpet = add_prefix(meanpet_file,'w');

if(nargin==4)
    varargout{1} = add_prefix(dynamic_pet,'w');
    h = add_prefix(dynamic_pet,'w');
    varargout{1} = h{1}(1:end-2);    
end

end