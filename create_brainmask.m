function brainmask = create_brainmask(subject,bet_file,varargin)

[outdir,name] = fileparts(bet_file);
if(~strcmpi(name,'brainmask'))
    brainmask = sprintf('%s/brainmask.nii',outdir);
else
    outdir = sprintf('%s/%s/PET',getenv('DATA_DIR'),subject);
    brainmask = sprintf('%s/brainmask.nii',outdir);
end
if(~exist(brainmask,'file'))
    V = spm_vol(bet_file);
    img = metpet_fill_brain_img(logical(spm_read_vols(V)));
    V.fname = brainmask;
    V.dt = [spm_type('uint8') spm_platform('bigend')];
    V.pinfo = [Inf Inf Inf]';
    if(nargin==3)
        specific_binding_mask = varargin{1};
        if(ischar(specific_binding_mask))
            W = spm_vol(specific_binding_mask);
            specific_binding_mask = spm_read_vols(W);
        end
        img = specific_binding_mask.*img;
    end
    spm_write_vol(V,uint8(img));
end

end
