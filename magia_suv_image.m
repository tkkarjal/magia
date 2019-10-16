function suv_img_file = magia_suv_image(pet_file,dose,weight,brainmask,outputdir)

V = spm_vol(pet_file);
img = spm_read_vols(V);
c = dose/weight;
suv_img = img./c;

V = spm_vol(brainmask);
mask = spm_read_vols(V);
suv_img = suv_img.*double(logical(mask));

[~,n] = fileparts(pet_file);

suv_img_file = sprintf('%s/%s_suv.nii',outputdir,n);
V.fname = suv_img_file;
V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';
spm_write_vol(V,suv_img);

end