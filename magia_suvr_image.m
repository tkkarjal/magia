function suvr_image_file = magia_suvr_image(start_time,end_time,input,frames,pet_filename,brainmask,outputdir)

if(ischar(brainmask))
    V = spm_vol(brainmask);
    brainmask = spm_read_vols(V);
    brainmask(isnan(brainmask)) = 0;
    clear V
end

num_frames = size(frames,1);
V = spm_vol(pet_filename);
img = spm_read_vols(V);
siz = size(img);
if(num_frames > 1)
    tacs = reshape(img,prod(siz(1:3)),siz(4));
else
    tacs = reshape(img,prod(siz(1:3)),1);
end

suvr = magia_suvr(input,tacs,frames,start_time,end_time);
suvr_image = reshape(suvr,siz(1:3)).*brainmask;
clear suvr

[~,n] = fileparts(pet_filename);
if(num_frames > 1)
    V = V(1);
end
V.fname = sprintf('%s/%s_suvr.nii',outputdir,n);
V.dt = [spm_type('int16') spm_platform('bigend')];
V.pinfo = [Inf Inf Inf]';
spm_write_vol(V,suvr_image);

suvr_image_file = V.fname;

end
