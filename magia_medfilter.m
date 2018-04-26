function new_image = magia_medfilter(old_image)

new_image = old_image;
for z = 1:size(old_image,3)
    old_slice = old_image(:,:,z);
    new_slice = magia_medfilter_slice(old_slice);
    new_image(:,:,z) = new_slice;
end

end