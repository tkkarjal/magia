function write_4d_nifti(V,img,filename)

nt = size(img,4);
V.fname = filename;

for i = 1:nt
    V.n(1) = i;
    im = squeeze(img(:,:,:,i));
    spm_write_vol(V,im);
end

end