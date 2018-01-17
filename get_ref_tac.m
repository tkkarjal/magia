function ref_tac = get_ref_tac(pet_image,ref_mask)

if(ischar(pet_image))
    V = spm_vol(pet_image);
    pet_image = spm_read_vols(V);
    clear V
end
if(ischar(ref_mask))
    V = spm_vol(ref_mask);
    ref_mask = spm_read_vols(V);
    clear V
end

ref_mask = logical(ref_mask);
M = size(pet_image,4);
ref_tac = zeros(M,1);
for i = 1:M
    img = squeeze(pet_image(:,:,:,i));
    ref_values = img(ref_mask);
    ref_values = ref_values(~isnan(ref_values));   
    ref_tac(i) = mean(ref_values);
end

end