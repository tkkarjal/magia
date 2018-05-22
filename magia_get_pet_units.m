function bq = magia_get_pet_units(pet_image)

if(ischar(pet_image))
    V = spm_vol(pet_image);
    pet_image = spm_read_vols(V);
end

maxval = max(pet_image(:));

if(maxval > 500)
    bq = 1;
else
    bq = 0;
end

end
