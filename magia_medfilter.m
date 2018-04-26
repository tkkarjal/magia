function new_image = magia_medfilter(old_image)

if(ischar(old_image))
    V = spm_vol(old_image);
    old_image = spm_read_vols(V);
    clear V
end

new_image = old_image;
for z = 1:size(old_image,3)
    old_slice = old_image(:,:,z);
    new_slice = magia_medfilter_slice(old_slice);
    new_image(:,:,z) = new_slice;
end

end
