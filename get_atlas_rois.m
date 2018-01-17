function roi_info = get_atlas_rois(mask_dir)

f = get_filenames(mask_dir,'*.nii');
[~,roi_info.labels] = cellfun(@fileparts,f,'UniformOutput',0);

end