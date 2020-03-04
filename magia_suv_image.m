function suv_img_file = magia_suv_image(pet_file,dose,weight,brainmask,outputdir)

V = spm_vol(brainmask);
mask = spm_read_vols(V) > 0;

V = spm_vol(pet_file);
img = spm_read_vols(V);
c = dose/weight;
suv_img = img./c;

for i = 1:size(suv_img,4)
    h = squeeze(suv_img(:,:,:,i)).*mask;
    suv_img(:,:,:,i) = h;
end

[~,n] = fileparts(pet_file);

suv_img_file = sprintf('%s/%s_suv.nii',outputdir,n);
write_4d_nifti(V(1),suv_img,suv_img_file);

end