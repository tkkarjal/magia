function roi_info = magia_get_roi_info(roi_set,tracer)

if(strcmpi(roi_set,'tracer_default'))
    roi_info = get_tracer_default_roi_set(tracer);
elseif(strcmpi(roi_set,'atlas'))
    mask_dir = '/scratch/shared/megapet/masks';
    roi_info = get_atlas_rois(mask_dir);
    roi_info.mask_dir = mask_dir;
elseif(strcmpi(roi_set,'[18f]fdg_atlas'))
    mask_dir = '/scratch/shared/megapet/fdg_rois';
    roi_info = get_atlas_rois(mask_dir);
    roi_info.mask_dir = mask_dir;
elseif(strcmpi(roi_set,'bug_12_roi'))
    mask_dir = '/scratch/shared/megapet/masks/bug_12_roi';
    roi_info = get_atlas_rois(mask_dir);
    roi_info.mask_dir = mask_dir;
elseif(strcmpi(roi_set,'[11c]raclopride_atlas'))
    mask_dir = '/scratch/shared/megapet/raclo_rois';
    roi_info = get_atlas_rois(mask_dir);
    roi_info.mask_dir = mask_dir;
else
    roi_info = read_roi_info(roi_set);
end

end
