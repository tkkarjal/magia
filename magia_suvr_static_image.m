function static_ratio_image = magia_suvr_static_image(input,pet_filename,brainmask,outputdir)

V = spm_vol(pet_filename);
pet_image = spm_read_vols(V);
static_ratio_image = brainmask.*pet_image./input;

[~,n] = fileparts(pet_filename);

V.fname = sprintf('%s/%s_suvr_static.nii',outputdir,n);
V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';
spm_write_vol(V,static_ratio_image);

static_ratio_image = V.fname;

end