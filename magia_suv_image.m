function suv_img_file = magia_suv_image(pet_file,dose,weight)

[p,n] = fileparts(pet_file);
files = cellstr(spm_select('ExtList',p,n));
suv_factor = dose/weight;

n_frames = size(files,1);
suv_img_file = sprintf('%s/%s_suv.nii',p,n);
for i = 1:n_frames
    file = files{i};
    V = spm_vol(file);
    img = spm_read_vols(V);
    m = max(img(:));
    if(m > 1000)
        img = img.*0.001;
    end
    img2 = suv_factor.*img;
    V.fname = suv_img_file;
    V.n(1) = i;
    spm_write_vol(V,img2);
end

end