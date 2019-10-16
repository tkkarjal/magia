function [tacs,num_voxels] = magia_calculate_roi_tacs(pet_image,roi_masks)

if(ischar(pet_image))
    V = spm_vol(pet_image);
    pet_image = spm_read_vols(V);
    clear V
end

if(iscell(roi_masks))
    M = length(roi_masks);
    temp = zeros([size(pet_image,1) size(pet_image,2) size(pet_image,3) M]);
    for r = 1:M
        V = spm_vol(roi_masks{r});
        temp(:,:,:,r) = spm_read_vols(V);
    end
    roi_masks = temp;
    clear temp V
elseif(ischar(roi_masks))
    V = spm_vol(roi_masks);
    roi_masks = spm_read_vols(V);
    clear V
end

N = size(roi_masks,4);
M = size(pet_image,4);
tacs = zeros(N,M);
num_voxels = zeros(N,1);

for r = 1:N
    mask = squeeze(roi_masks(:,:,:,r));
    mask(isnan(mask)) = 0;
    mask = logical(mask);
    for i = 1:M
        img = squeeze(pet_image(:,:,:,i));
        tacs(r,i) = mean(img(mask),'omitnan');
    end
    num_voxels(r) = sum(mask(:));
end

end