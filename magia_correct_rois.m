function magia_correct_rois(roi_masks,meanpet_image)

if(ischar(roi_masks))
    roi_masks = {roi_masks};
end
if(ischar(meanpet_image))
    V = spm_vol(meanpet_image);
    meanpet_image = spm_read_vols(V);
    clear V;
end

N = length(roi_masks);

for i = 1:N
    mask_file = roi_masks{i};
    V = spm_vol(mask_file);
    mask_image = spm_read_vols(V);
    corrected_mask = magia_roi_correction(mask_image,meanpet_image);
    spm_write_vol(V,corrected_mask);
end

end