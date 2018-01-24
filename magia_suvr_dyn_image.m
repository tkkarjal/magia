function suvr_image_file = magia_suvr_dyn_image(startTime,endTime,input,frames,pet_filename,brainmask,outputdir)

if(ischar(brainmask))
    V = spm_vol(brainmask);
    brainmask = spm_read_vols(V);
    brainmask(isnan(brainmask)) = 0;
    clear V
end

V = spm_vol(pet_filename);
img = spm_read_vols(V);
siz = size(img);
tacs = reshape(img,prod(siz(1:3)),siz(4));
suvr = magia_suvr_dyn(input,tacs,frames,startTime,endTime);
suvr_image = reshape(suvr,siz(1:3)).*brainmask;
clear suvr

[~,n] = fileparts(pet_filename);
V = V(1);
V.fname = sprintf('%s/%s_suvr_dyn.nii',outputdir,n);
V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';
spm_write_vol(V,suvr_image);

suvr_image_file = V.fname;

end